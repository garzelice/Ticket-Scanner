//
//  Medusa.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 14.03.25.
//

import Dependencies
import Observation
import SQLiteData
import SwiftUI

@Observable
@MainActor
class Medusa {
    var isAuthenticated = false
    var serverName: String?
    var user: User = .init()
    var products: [Product] = []
    var salesChannels: [SalesChannel] = []
    var selectedSalesChannel: SalesChannel?
    var tickets: [TicketRecord] = []
    var pendingSyncCount: Int = 0
    var isSyncing: Bool = false

    private let apiService = APIService()
    
    @ObservationIgnored @Dependency(\.defaultDatabase) var database

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
    
    func loadTickets() async {
        do {
            tickets = try await database.read { db in
                try TicketRecord.fetchAll(db)
            }
            pendingSyncCount = tickets.filter { $0.needsSync }.count
        } catch {
            print("Failed to load tickets: \(error)")
        }
    }

	func syncTickets(auth: Auth, isOnline: Bool) async {
		guard isOnline else { return }
		guard let server = Server(url: auth.medusaUrl, token: auth.medusaToken) else { return }
		
		isSyncing = true
		defer { isSyncing = false }
		
		do {
			var serverTickets: [Ticket] = []
			var offset = 0
			let pageSize = 100
			
			while true {
				print("[Pagination] Fetching tickets offset=\(offset) limit=\(pageSize)")
				let response = try await apiService.getTickets(server: server, offset: offset, limit: pageSize)
				let fetchedCount = response.data?.count ?? 0
				print("[Pagination] Got \(fetchedCount) tickets | count=\(response.count ?? -1) limit=\(response.limit ?? -1) offset=\(response.offset ?? -1)")
				
				if let tickets = response.data {
					serverTickets.append(contentsOf: tickets)
				}
				
				if let totalCount = response.count {
					// Backend provided total count; use it to decide if we're done
					offset += pageSize
					if offset >= totalCount {
						print("[Pagination] Reached end: offset=\(offset) >= count=\(totalCount)")
						break
					}
				} else {
					// No total count from backend — stop when we got fewer items than requested
					if fetchedCount < pageSize {
						print("[Pagination] Reached end: fetched \(fetchedCount) < pageSize \(pageSize)")
						break
					}
					offset += pageSize
				}
			}
			
			print("[Pagination] Total tickets fetched: \(serverTickets.count)")
            
            let syncedTickets = serverTickets
            
            let existingTickets: [TicketRecord] = try await database.read { db in
                try TicketRecord.fetchAll(db)
            }
            
            try await database.write { db in
                for serverTicket in syncedTickets {
                    guard let ticketId = serverTicket.id else { continue }
                    
                    let existing = existingTickets.first { $0.id == ticketId }
                    
                    let isScanned = existing?.isScanned ?? false
                    let scannedAt = existing?.scannedAt
                    let needsSync = existing?.needsSync ?? false
                    let status = existing?.status ?? serverTicket.status
                    
                    try db.execute(
                        sql: """
                            INSERT OR REPLACE INTO ticketRecords 
                            (id, hash, customerId, status, expiresAt, createdAt, eventId, ticketTypeId, ticketTypeName, customerEmail, orderDisplayId, isScanned, scannedAt, needsSync)
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                            """,
                        arguments: [
                            ticketId,
                            serverTicket.hash,
                            serverTicket.customer_id,
                            status,
                            serverTicket.expires_at,
                            serverTicket.created_at,
                            serverTicket.event_id,
                            serverTicket.ticket_type_id,
                            serverTicket.ticket_type_name,
                            serverTicket.customer_email,
                            serverTicket.order_display_id,
                            isScanned ? 1 : 0,
                            scannedAt,
                            needsSync ? 1 : 0
                        ]
                    )
                }
            }
            
            await loadTickets()
            
            await syncPendingScans(auth: auth, isOnline: isOnline)
        } catch {
            print("Failed to sync tickets: \(error)")
        }
    }

    func syncPendingScans(auth: Auth, isOnline: Bool) async {
        print("is online: ")
        print(isOnline)
        guard isOnline else { return }
        guard let server = Server(url: auth.medusaUrl, token: auth.medusaToken) else { return }
        
        let pendingTickets = tickets.filter { $0.needsSync }
        
        for ticket in pendingTickets {
            guard let hash = ticket.hash else { continue }
            do {
                _ = try await apiService.scanTicket(server: server, ticketHash: hash)
                try await database.write { db in
                    try db.execute(
                        sql: "UPDATE ticketRecords SET isScanned = 1, needsSync = 0 WHERE id = ?",
                        arguments: [ticket.id]
                    )
                }
            } catch {
                print("Failed to sync scan for ticket \(ticket.id): \(error)")
            }
        }
        
        await loadTickets()
    }

    func markTicketScanned(_ ticketHash: String, isOnline: Bool, auth: Auth) async {
        print("marking ticket as scanned")
        
        do {
            try await database.write { db in
                try db.execute(
                    sql: "UPDATE ticketRecords SET isScanned = 1, scannedAt = ?, needsSync = 1 WHERE hash = ?",
                    arguments: [Date(), ticketHash]
                )
            }
            await loadTickets()
        } catch {
            print("Failed to mark ticket scanned: \(error)")
        }
        
        if isOnline {
            await syncPendingScans(auth: auth, isOnline: isOnline)
        }
    }

    func markTicketUnscanned(_ ticketId: String) async {
        do {
            try await database.write { db in
                try db.execute(
                    sql: "UPDATE ticketRecords SET isScanned = 0, scannedAt = NULL, needsSync = 0, status = 'active' WHERE id = ?",
                    arguments: [ticketId]
                )
            }
            await loadTickets()
        } catch {
            print("Failed to mark ticket unscanned: \(error)")
        }
    }

    func clearTickets() async {
        do {
            try await database.write { db in
                try db.execute(sql: "DELETE FROM ticketRecords")
            }
            tickets = []
            pendingSyncCount = 0
        } catch {
            print("Failed to clear tickets: \(error)")
        }
    }

    func reset() async {
        await clearTickets()
        isAuthenticated = false
        serverName = nil
        user = User()
        products = []
        salesChannels = []
        selectedSalesChannel = nil
        isSyncing = false
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
