//
//  Medusa.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 14.03.25.
//

import Observation
import SwiftUI

@Observable
@MainActor
class Medusa {
    // Authentication gate still used by App; will be set externally after Auth login.
    var isAuthenticated = false
    var serverName: String?
    var user: User = .init()
    var products: [Product] = []
    var salesChannels: [SalesChannel] = []
	var selectedSalesChannel: SalesChannel?
	var tickets: [Ticket] = []

    private let apiService = APIService()

    // Source of truth for url/token now lives in Auth. We'll inject when calling methods.
    func getSalesChannels(auth: Auth) async {
        guard let server = Server(url: auth.medusaUrl, token: auth.medusaToken) else { return }
        
		if let salesChannels = try? await apiService.getSalesChannels(server: server) {
			self.salesChannels = salesChannels
			self.selectedSalesChannel = salesChannels[0]
		}
    }

    func getProducts(auth: Auth, salesChannelId: String? = nil, debug: Bool = false) {
        guard let server = Server(url: auth.medusaUrl, token: auth.medusaToken) else { return }
        apiService.getProducts(server: server, salesChannelId: salesChannelId, debug: debug) { (result: Result<[Product], Authentication.AuthenticationError>) in
            switch result {
            case let .success(products):
                self.products = products
            case let .failure(err):
                print(err.localizedDescription)
            }
        }
    }
	
	func getTickets(auth: Auth, debug: Bool = false) async {
		guard let server = Server(url: auth.medusaUrl, token: auth.medusaToken) else { return }
		do {
			tickets = try await apiService.getTickets(server: server)
		} catch {
			print(error)
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

struct Server: Sendable {
    let url: URL
    let token: String
    init?(url: URL?, token: String?) {
        guard let url, let token else { return nil }
        self.url = url
        self.token = token
    }
}
