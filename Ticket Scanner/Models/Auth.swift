//
//  Auth.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 12.08.25.
//


import Foundation
@preconcurrency import KeychainSwift
import SwiftUI

@Observable
public final class Auth: @unchecked Sendable {
    let keychain = KeychainSwift()
    private let apiService = APIService.shared

    public private(set) var medusaToken: String?
    public private(set) var medusaUrl: String?
    // Persisted store name (to be fetched later from Medusa backend /store)
    public private(set) var storeName: String?

    public var isAuthenticated: Bool {
        medusaToken != nil
    }

    public func logout() {
        keychain.delete("medusa_token")
        keychain.delete("medusa_url")
        keychain.delete("medusa_store_name")
        medusaToken = nil
        medusaUrl = nil
        storeName = nil
    }

    public init() {
        medusaToken = keychain.get("medusa_token")
        medusaUrl = keychain.get("medusa_url")
        storeName = keychain.get("medusa_store_name")
    }

    // First step: set & persist server URL only (resets token if server changes)
    public func setServerUrl(_ url: String) {
        // Only act if changed
        if medusaUrl != url {
            keychain.set(url, forKey: "medusa_url")
            medusaUrl = url
            // Invalidate token because different server
            if medusaToken != nil { logoutTokenOnly() }
        }
    }

    // Persist (or clear) store name
    public func setStoreName(_ name: String?) {
        storeName = name
        if let name = name, !name.isEmpty {
            keychain.set(name, forKey: "medusa_store_name")
        } else {
            keychain.delete("medusa_store_name")
        }
    }

    private func logoutTokenOnly() {
        keychain.delete("medusa_token")
        medusaToken = nil
    }

    public func authenticate(url: String, email: String, password: String) async throws {
        guard let serverUrl = URL(string: url) else {
            throw Authentication.AuthenticationError.custom(errorMessage: "Invalid URL")
        }

        return try await withCheckedThrowingContinuation { continuation in
            apiService.login(url: serverUrl, email: email, password: password) { result in
                switch result {
                case .success(let token):
                    self.keychain.set(token, forKey: "medusa_token")
                    self.keychain.set(url, forKey: "medusa_url")
                    self.medusaToken = token
                    self.medusaUrl = url
                    continuation.resume(returning: ())
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func refresh() async {
        guard let urlString = medusaUrl, let token = medusaToken else {
            await MainActor.run {
                self.logout()
            }
            return
        }

        let server = Server()
        server.url = urlString
        server.token = token

        let result = await withCheckedContinuation { continuation in
            apiService.verifyLogin(server: server) { (result: Result<String, Authentication.AuthenticationError>) in
                continuation.resume(returning: result)
            }
        }

        await MainActor.run {
            switch result {
            case .success(let newToken):
                self.keychain.set(newToken, forKey: "medusa_token")
                self.medusaToken = newToken
            case .failure:
                self.logout()
            }
        }
    }
}
