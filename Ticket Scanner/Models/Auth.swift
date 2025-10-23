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
	public private(set) var medusaUrl: URL?
	// Persisted store name (to be fetched later from Medusa backend /store)
	public private(set) var storeName: String?

	public var isAuthenticated: Bool {
		medusaToken != nil
	}

	public func logout() {
		keychain.delete("medusa_token")
		//        keychain.delete("medusa_url")
		keychain.delete("medusa_store_name")
		medusaToken = nil
		//        medusaUrl = nil
		storeName = nil
	}

	public func logoutAndClearServerUrl() {
		logout()
		keychain.delete("medusa_url")
		medusaUrl = nil
	}

	public init() {
		medusaToken = keychain.get("medusa_token")
		if let storedUrl = keychain.get("medusa_url") {
			medusaUrl = URL(string: storedUrl)
		}
		storeName = keychain.get("medusa_store_name")
	}

	public func setServerUrl(_ url: String) throws {
		guard let url = URL(string: url) else {
			print("Couldn’t parse URL")
			throw Authentication.AuthenticationError.custom(errorMessage: "Invalid URL")
		}
		// Only act if changed
		if medusaUrl != url {
			keychain.set(url.absoluteString, forKey: "medusa_url")
			medusaUrl = url
			// Invalidate token because different server
			if medusaToken != nil { logout() }
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

	public func authenticate(email: String, password: String) async throws {
		guard let url = medusaUrl else {
			throw Authentication.AuthenticationError.custom(errorMessage: "No server URL set")
		}

		let result = await apiService.login(url: url, email: email, password: password)

		switch result {
		case .success(let token):
			self.keychain.set(token, forKey: "medusa_token")
			self.keychain.set(url.absoluteString, forKey: "medusa_url")
			self.medusaToken = token
			self.medusaUrl = url
		case .failure(let error):
			throw error
		}
	}

	public func refresh() async {
		guard let urlString = medusaUrl, let token = medusaToken else {
			await MainActor.run {
				self.logout()
			}
			return
		}

		guard let server = Server(url: urlString, token: token) else { return }

		let result = await withCheckedContinuation { continuation in
			apiService.verifyLogin(server: server) {
				(result: Result<String, Authentication.AuthenticationError>) in
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
