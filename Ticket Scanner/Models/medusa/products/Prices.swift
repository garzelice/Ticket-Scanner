import Foundation

struct Prices: Codable {
    let id: String
    let amount: Int?
    let currency_code: String?
    let min_quantity: String?
    let max_quantity: String?
    let variant_id: String?
    let created_at: String?
    let updated_at: String?

    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case currency_code
        case min_quantity
        case max_quantity
        case variant_id
        case created_at
        case updated_at
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        amount = try values.decodeIfPresent(Int.self, forKey: .amount)
        currency_code = try values.decodeIfPresent(String.self, forKey: .currency_code)
        min_quantity = try values.decodeIfPresent(String.self, forKey: .min_quantity)
        max_quantity = try values.decodeIfPresent(String.self, forKey: .max_quantity)
        variant_id = try values.decodeIfPresent(String.self, forKey: .variant_id)
        created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
        updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
    }
}
