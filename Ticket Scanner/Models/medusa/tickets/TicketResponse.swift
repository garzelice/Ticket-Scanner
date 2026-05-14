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
	let count: Int?
	let limit: Int?
	let offset: Int?

	enum CodingKeys: String, CodingKey {
		case success = "success"
		case data = "data"
		case message = "message"
		case timestamp = "timestamp"
		case count = "count"
		case limit = "limit"
		case offset = "offset"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		success = try values.decodeIfPresent(Bool.self, forKey: .success)
		data = try values.decodeIfPresent([Ticket].self, forKey: .data)
		message = try values.decodeIfPresent(String.self, forKey: .message)
		timestamp = try values.decodeIfPresent(String.self, forKey: .timestamp)
		count = try values.decodeIfPresent(Int.self, forKey: .count)
		limit = try values.decodeIfPresent(Int.self, forKey: .limit)
		offset = try values.decodeIfPresent(Int.self, forKey: .offset)
	}

}
