//
//  Ticket.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 12.08.25.
//

import Foundation
struct Ticket : Codable {
	let id : String?
	let hash : String?
	let customer_id : String?
	let status : String?
	let expires_at : String?
	let created_at : String?
	let event_id : String?
	let ticket_type_id : String?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case hash = "hash"
		case customer_id = "customer_id"
		case status = "status"
		case expires_at = "expires_at"
		case created_at = "created_at"
		case event_id = "event_id"
		case ticket_type_id = "ticket_type_id"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		hash = try values.decodeIfPresent(String.self, forKey: .hash)
		customer_id = try values.decodeIfPresent(String.self, forKey: .customer_id)
		status = try values.decodeIfPresent(String.self, forKey: .status)
		expires_at = try values.decodeIfPresent(String.self, forKey: .expires_at)
		created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
		event_id = try values.decodeIfPresent(String.self, forKey: .event_id)
		ticket_type_id = try values.decodeIfPresent(String.self, forKey: .ticket_type_id)
	}

}
