import Foundation
struct Product: Codable, Identifiable {
	let id: String
	let title: String?
	let subtitle: String?
	let status: String?
	let external_id: String?
	let description: String?
	let handle: String?
	let is_giftcard: Bool?
	let discountable: Bool?
	let thumbnail: String?
	let collection_id: String?
	let type_id: String?
	let weight: String?
	let length: String?
	let height: String?
	let width: String?
	let hs_code: String?
	let origin_country: String?
	let mid_code: String?
	let material: String?
	let created_at: String?
	let updated_at: String?
	let deleted_at: String?
	let metadata: String?
	let type: String?
	let collection: String?
	let options: [Options]?
	let tags: [String]?
	let images: [Images]?
	let variants: [Variants]?
	let sales_channels: [Sales_channels]?

	enum CodingKeys: String, CodingKey {
		case id = "id"
		case title = "title"
		case subtitle = "subtitle"
		case status = "status"
		case external_id = "external_id"
		case description = "description"
		case handle = "handle"
		case is_giftcard = "is_giftcard"
		case discountable = "discountable"
		case thumbnail = "thumbnail"
		case collection_id = "collection_id"
		case type_id = "type_id"
		case weight = "weight"
		case length = "length"
		case height = "height"
		case width = "width"
		case hs_code = "hs_code"
		case origin_country = "origin_country"
		case mid_code = "mid_code"
		case material = "material"
		case created_at = "created_at"
		case updated_at = "updated_at"
		case deleted_at = "deleted_at"
		case metadata = "metadata"
		case type = "type"
		case collection = "collection"
		case options = "options"
		case tags = "tags"
		case images = "images"
		case variants = "variants"
		case sales_channels = "sales_channels"
	}
	
	init(id: String, title: String?, subtitle: String?, status: String?, external_id: String?, description: String?, handle: String?, is_giftcard: Bool?, discountable: Bool?, thumbnail: String?, collection_id: String?, type_id: String?, weight: String?, length: String?, height: String?, width: String?, hs_code: String?, origin_country: String?, mid_code: String?, material: String?, created_at: String?, updated_at: String?, deleted_at: String?, metadata: String?, type: String?, collection: String?, options: [Options]?, tags: [String]?, images: [Images]?, variants: [Variants]?, sales_channels: [Sales_channels]?) {
		self.id = id
		self.title = title
		self.subtitle = subtitle
		self.status = status
		self.external_id = external_id
		self.description = description
		self.handle = handle
		self.is_giftcard = is_giftcard
		self.discountable = discountable
		self.thumbnail = thumbnail
		self.collection_id = collection_id
		self.type_id = type_id
		self.weight = weight
		self.length = length
		self.height = height
		self.width = width
		self.hs_code = hs_code
		self.origin_country = origin_country
		self.mid_code = mid_code
		self.material = material
		self.created_at = created_at
		self.updated_at = updated_at
		self.deleted_at = deleted_at
		self.metadata = metadata
		self.type = type
		self.collection = collection
		self.options = options
		self.tags = tags
		self.images = images
		self.variants = variants
		self.sales_channels = sales_channels
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
		title = try values.decodeIfPresent(String.self, forKey: .title)
		subtitle = try values.decodeIfPresent(String.self, forKey: .subtitle)
		status = try values.decodeIfPresent(String.self, forKey: .status)
		external_id = try values.decodeIfPresent(String.self, forKey: .external_id)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		handle = try values.decodeIfPresent(String.self, forKey: .handle)
		is_giftcard = try values.decodeIfPresent(Bool.self, forKey: .is_giftcard)
		discountable = try values.decodeIfPresent(Bool.self, forKey: .discountable)
		thumbnail = try values.decodeIfPresent(String.self, forKey: .thumbnail)
		collection_id = try values.decodeIfPresent(String.self, forKey: .collection_id)
		type_id = try values.decodeIfPresent(String.self, forKey: .type_id)
		weight = try values.decodeIfPresent(String.self, forKey: .weight)
		length = try values.decodeIfPresent(String.self, forKey: .length)
		height = try values.decodeIfPresent(String.self, forKey: .height)
		width = try values.decodeIfPresent(String.self, forKey: .width)
		hs_code = try values.decodeIfPresent(String.self, forKey: .hs_code)
		origin_country = try values.decodeIfPresent(String.self, forKey: .origin_country)
		mid_code = try values.decodeIfPresent(String.self, forKey: .mid_code)
		material = try values.decodeIfPresent(String.self, forKey: .material)
		created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
		updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
		deleted_at = try values.decodeIfPresent(String.self, forKey: .deleted_at)
		metadata = try values.decodeIfPresent(String.self, forKey: .metadata)
		type = try values.decodeIfPresent(String.self, forKey: .type)
		collection = try values.decodeIfPresent(String.self, forKey: .collection)
		options = try values.decodeIfPresent([Options].self, forKey: .options)
		tags = try values.decodeIfPresent([String].self, forKey: .tags)
		images = try values.decodeIfPresent([Images].self, forKey: .images)
		variants = try values.decodeIfPresent([Variants].self, forKey: .variants)
		sales_channels = try values.decodeIfPresent([Sales_channels].self, forKey: .sales_channels)
	}

	func example() -> Product {
		return Product(id: UUID().uuidString, title: <#T##String?#>, subtitle: <#T##String?#>, status: <#T##String?#>, external_id: <#T##String?#>, description: <#T##String?#>, handle: <#T##String?#>, is_giftcard: <#T##Bool?#>, discountable: <#T##Bool?#>, thumbnail: <#T##String?#>, collection_id: <#T##String?#>, type_id: <#T##String?#>, weight: <#T##String?#>, length: <#T##String?#>, height: <#T##String?#>, width: <#T##String?#>, hs_code: <#T##String?#>, origin_country: <#T##String?#>, mid_code: <#T##String?#>, material: <#T##String?#>, created_at: <#T##String?#>, updated_at: <#T##String?#>, deleted_at: <#T##String?#>, metadata: <#T##String?#>, type: <#T##String?#>, collection: <#T##String?#>, options: <#T##[Options]?#>, tags: <#T##[String]?#>, images: <#T##[Images]?#>, variants: <#T##[Variants]?#>, sales_channels: <#T##[Sales_channels]?#>)
	}
}
