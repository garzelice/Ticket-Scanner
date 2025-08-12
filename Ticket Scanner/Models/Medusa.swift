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
    var isAuthenticated = false

    var serverName: String?

    var server: Server = .init()
    var user: User = .init()
    var products: [Product] = []
    var salesChannels: [SalesChannel] = []

    // Add API service as a property
    private let apiService = APIService()

    // Add methods that use the API service
    func login(url: URL, email: String, password: String, completion: @escaping (Bool) -> Void) {
        apiService.login(url: url, email: email, password: password) { result in
            switch result {
            case let .success(token):
                // Store token and update state
                UserDefaults.standard.set(token, forKey: "token")
                self.isAuthenticated = true
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

    func saveToken(token: String) {
        server.token = token
        UserDefaults.standard.set(token, forKey: "token")
    }

    func saveUrl(url: String) {
        server.url = url
        UserDefaults.standard.set(url, forKey: "medusaUrl")
    }

    func getSalesChannels() {
		Task {
			if let salesChannels = try? await apiService.getSalesChannels(server: server) {
				self.salesChannels = salesChannels
			}
		}
    }

    func getProducts() {
        apiService.getProducts(server: server) { (result: Result<[Product], Authentication.AuthenticationError>) in
            switch result {
            case let .success(products):
                self.products = products
            case let .failure(err):
                print(err.localizedDescription)
            }
        }
    }

    init() {
        user = User()

        if let url = UserDefaults.standard.string(forKey: "medusaUrl"), let token = UserDefaults.standard.string(forKey: "token") {
            server.url = url
            server.token = token

            // If URL and Token are set, try to verify the user
            apiService.verifyLogin(server: server) { (result: Result<String, Authentication.AuthenticationError>) in
                switch result {
                case let .success(token):
                    self.saveToken(token: token)
                    self.isAuthenticated = true
                case let .failure(error):
                    print(error)
                    self.isAuthenticated = false
                }
            }
        }
    }

    init(user: User, server: Server, products: [Product]) {
        isAuthenticated = true
        self.user = user
        self.server = server
        self.products = products
    }
}

class User {
    var name: String?
}

class Server {
    var url: String?
    var token: String?
}
