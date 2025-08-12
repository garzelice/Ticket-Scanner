//
//  Medusa.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 14.03.25.
//

import Observation
import SwiftUI

@Observable
class Medusa {
    // Authentication gate still used by App; will be set externally after Auth login.
    var isAuthenticated = false
    var serverName: String?
    var user: User = .init()
    var products: [Product] = []
    var salesChannels: [SalesChannel] = []

    private let apiService = APIService()

    // Source of truth for url/token now lives in Auth. We'll inject when calling methods.
    func getSalesChannels(auth: Auth) {
        guard let urlString = auth.medusaUrl, let token = auth.medusaToken else { return }
        let server = Server(); server.url = urlString; server.token = token
        Task {
            if let salesChannels = try? await apiService.getSalesChannels(server: server) {
                self.salesChannels = salesChannels
            }
        }
    }

    func getProducts(auth: Auth, salesChannelId: String? = nil) {
        guard let urlString = auth.medusaUrl, let token = auth.medusaToken else { return }
        let server = Server(); server.url = urlString; server.token = token
        apiService.getProducts(server: server, salesChannelId: salesChannelId) { (result: Result<[Product], Authentication.AuthenticationError>) in
            switch result {
            case let .success(products):
                self.products = products
            case let .failure(err):
                print(err.localizedDescription)
            }
        }
    }

    func refreshAuth(auth: Auth) async {
        await auth.refresh()
        isAuthenticated = auth.isAuthenticated
    }

    init() {}
}

class User {
    var name: String?
}

class Server {
    var url: String?
    var token: String?
}
