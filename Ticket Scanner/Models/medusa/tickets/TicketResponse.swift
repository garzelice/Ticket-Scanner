//
//  TicketResponse.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 12.08.25.
//

import Foundation
struct TicketResponse: Codable {
	let success : Bool?
	let data : [Ticket]?
	let message : String?
	let timestamp : String?

	enum CodingKeys: String, CodingKey {
		case success = "success"
		case data = "data"
		case message = "message"
		case timestamp = "timestamp"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		success = try values.decodeIfPresent(Bool.self, forKey: .success)
		data = try values.decodeIfPresent([Ticket].self, forKey: .data)
		message = try values.decodeIfPresent(String.self, forKey: .message)
		timestamp = try values.decodeIfPresent(String.self, forKey: .timestamp)
	}

}
