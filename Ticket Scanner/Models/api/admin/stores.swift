//
//  stores.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 12.08.25.
//

import Foundation

// MARK: - Welcome
struct StoresResponse: Codable {
	let stores: [Store]
	let count, offset, limit: Int
}

// MARK: - Store
struct Store: Codable {
	let id, name, defaultSalesChannelID, defaultRegionID: String
	let defaultLocationID: String
	let metadata: JSONNull?
	let createdAt, updatedAt: String
	let supportedCurrencies: [SupportedCurrency]

	enum CodingKeys: String, CodingKey {
		case id, name
		case defaultSalesChannelID
		case defaultRegionID
		case defaultLocationID
		case metadata
		case createdAt
		case updatedAt
		case supportedCurrencies
	}
}

// MARK: - SupportedCurrency
struct SupportedCurrency: Codable {
	let id, currencyCode: String
	let isDefault: Bool
	let storeID, createdAt, updatedAt: String
	let deletedAt: JSONNull?
	let currency: Currency

	enum CodingKeys: String, CodingKey {
		case id
		case currencyCode
		case isDefault
		case storeID
		case createdAt
		case updatedAt
		case deletedAt
		case currency
	}
}

// MARK: - Currency
struct Currency: Codable {
	let code, symbol, symbolNative, name: String
	let decimalDigits: Int
	let rawRounding: RawRounding
	let createdAt, updatedAt: String
	let deletedAt: JSONNull?
	let rounding: Int

	enum CodingKeys: String, CodingKey {
		case code, symbol
		case symbolNative
		case name
		case decimalDigits
		case rawRounding
		case createdAt
		case updatedAt
		case deletedAt
		case rounding
	}
}

// MARK: - RawRounding
struct RawRounding: Codable {
	let value: String
	let precision: Int
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

	public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
			return true
	}

	public var hashValue: Int {
			return 0
	}

	public init() {}

	public required init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()
			if !container.decodeNil() {
					throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
			}
	}

	public func encode(to encoder: Encoder) throws {
			var container = encoder.singleValueContainer()
			try container.encodeNil()
	}
}
