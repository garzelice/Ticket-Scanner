/*
 Copyright (c) 2025 Swift Models Generated from JSON powered by http://www.json4swift.com

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

 */

import Foundation

struct SalesChannel: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let name: String?
    let description: String?
    let is_disabled: Bool?
    let created_at: String?
    let updated_at: String?
    let deleted_at: String?
    let metadata: String?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        name = try values.decodeIfPresent(String.self, forKey: .name)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        is_disabled = try values.decodeIfPresent(Bool.self, forKey: .is_disabled)
        created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
        updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
        deleted_at = try values.decodeIfPresent(String.self, forKey: .deleted_at)
        metadata = try values.decodeIfPresent(String.self, forKey: .metadata)
    }
	
	static func example() -> SalesChannel {
		let JSON = """
		{
			"id": "sc_01JDFNTMA9FSSVQRV6T2HK6X3S",
			"name": "Default Sales Channel",
			"description": "Created by Medusa",
			"is_disabled": false,
			"created_at": "2024-11-24T18:09:31.465Z",
			"updated_at": "2024-11-24T18:09:31.465Z",
			"deleted_at": null,
			"metadata": null
		}
		"""
		return try! JSONDecoder().decode(SalesChannel.self, from: JSON.data(using: .utf8)!)
	}
	
	static func examples() -> [SalesChannel] {
		let JSON = #"[{"id":"sc_01JDFNTMA9FSSVQRV6T2HK6X3S","name":"Default Sales Channel","description":"Created by Medusa","is_disabled":false,"created_at":"2024-11-24T18:09:31.465Z","updated_at":"2024-11-24T18:09:31.465Z","deleted_at":null,"metadata":null},{"id":"sc_01JPFF4X39P7ARPQK86KV7GMP7","name":"Abendkasse","description":"Lol\n","is_disabled":false,"created_at":"2025-03-16T12:34:04.522Z","updated_at":"2025-03-16T12:34:04.522Z","deleted_at":null,"metadata":null}]"#
		return try! JSONDecoder().decode([SalesChannel].self, from: JSON.data(using: .utf8)!)
	}
}
