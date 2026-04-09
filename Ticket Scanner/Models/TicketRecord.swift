//
//  TicketRecord.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 12.08.25.
//

import Foundation
import SQLiteData

@Table struct TicketRecord: Identifiable {
    
    var id: String
    var hash: String?
    var customerId: String?
    var status: String?
    var expiresAt: String?
    var createdAt: String?
    var eventId: String?
    var ticketTypeId: String?
    var customerEmail: String?
    var orderDisplayId: Int?
    var isScanned: Bool
    var scannedAt: Date?
    var needsSync: Bool

    init(from ticket: Ticket) {
        self.id = ticket.id ?? UUID().uuidString
        self.hash = ticket.hash
        self.customerId = ticket.customer_id
        self.status = ticket.status
        self.expiresAt = ticket.expires_at
        self.createdAt = ticket.created_at
        self.eventId = ticket.event_id
        self.ticketTypeId = ticket.ticket_type_id
        self.customerEmail = ticket.customer_email
        self.orderDisplayId = ticket.order_display_id
        self.isScanned = false
        self.scannedAt = nil
        self.needsSync = false
    }

    init(
        id: String,
        hash: String? = nil,
        customerId: String? = nil,
        status: String? = nil,
        expiresAt: String? = nil,
        createdAt: String? = nil,
        eventId: String? = nil,
        ticketTypeId: String? = nil,
        customerEmail: String? = nil,
        orderDisplayId: Int? = nil,
        isScanned: Bool = false,
        scannedAt: Date? = nil,
        needsSync: Bool = false
    ) {
        self.id = id
        self.hash = hash
        self.customerId = customerId
        self.status = status
        self.expiresAt = expiresAt
        self.createdAt = createdAt
        self.eventId = eventId
        self.ticketTypeId = ticketTypeId
        self.customerEmail = customerEmail
        self.orderDisplayId = orderDisplayId
        self.isScanned = isScanned
        self.scannedAt = scannedAt
        self.needsSync = needsSync
    }
}