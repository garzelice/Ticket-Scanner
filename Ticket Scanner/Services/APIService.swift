//
//  APIService.swift
//  Ticket Scanner
//
//  Created by Eric Wätke on 08.03.25.
//

import Foundation

struct LoginRequestBody: Codable {
    let email: String
    let password: String
}

struct LoginResponseBody: Decodable {
    let token: String?
}

class APIService {
    static let shared = APIService()

    func login(url: URL,
               email: String,
               password: String,
               completion: @escaping (Result<String, Authentication.AuthenticationError>) -> Void)
    {
        let body = LoginRequestBody(email: email, password: password)

        var request = URLRequest(url: url.appending(path: "/auth/user/emailpass"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No Response from Medusa")))
                return
            }

            guard let loginResponse = try? JSONDecoder().decode(LoginResponseBody.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }

            guard let token = loginResponse.token else {
                completion(.failure(.invalidCredentials))
                return
            }

            completion(.success(token))
        }.resume()
    }

    func verifyLogin(server: Server,
                     completion: @escaping (Result<String, Authentication.AuthenticationError>) -> Void)
    {
        guard let urlString = server.url else {
            completion(.failure(.custom(errorMessage: "No Medusa URL Stored")))
            return
        }

        guard let url = URL(string: urlString) else {
            completion(.failure(.custom(errorMessage: "Couldn’t parse stored URL, it’s probably malformed")))
            return
        }

        guard let token = server.token else {
            completion(.failure(.custom(errorMessage: "No token available")))
            return
        }

        var request = URLRequest(url: url.appending(path: "/auth/token/refresh"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No Response from Medusa")))
                return
            }

            guard let loginResponse = try? JSONDecoder().decode(LoginResponseBody.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }

            guard let token = loginResponse.token else {
                completion(.failure(.invalidCredentials))
                return
            }

            completion(.success(token))
        }.resume()
    }

    func getProducts(server: Server,
                     salesChannelId: String? = nil,
                     completion: @escaping (Result<[Product], Authentication.AuthenticationError>) -> Void) {
        guard let urlString = server.url else {
            completion(.failure(.custom(errorMessage: "No Medusa URL Stored")))
            return
        }

        guard let url = URL(string: urlString) else {
            completion(.failure(.custom(errorMessage: "Couldn’t parse stored URL, it’s probably malformed")))
            return
        }

        guard let token = server.token else {
            completion(.failure(.custom(errorMessage: "No token available")))
            return
        }

        var components = URLComponents(url: url.appending(path: "/admin/products"), resolvingAgainstBaseURL: false)
        if let salesChannelId { // filter to selected sales channel
            components?.queryItems = [URLQueryItem(name: "sales_channel_id", value: salesChannelId)]
        }
        let finalUrl = components?.url ?? url.appending(path: "/admin/products")
        var request = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No Response from Medusa")))
                return
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys // keys already snake_case in models
            if let productResponse = try? decoder.decode(ProductResponse.self, from: data) {
                guard let products = productResponse.products else {
                    completion(.failure(.custom(errorMessage: "No Products")))
                    return
                }
                completion(.success(products))
            } else {
                // Debug: log raw JSON snippet (truncate for safety)
                let raw = String(data: data, encoding: .utf8) ?? "<non-utf8>"
                let truncated = raw.count > 1000 ? String(raw.prefix(1000)) + "…" : raw
                print("Product decode failed. Raw response:\n" + truncated)
                completion(.failure(.custom(errorMessage: "Invalid Product Schema")))
            }
        }.resume()
    }

	func getSalesChannels(server: Server) async throws -> [SalesChannel] {
        guard let urlString = server.url else {
			throw Authentication.AuthenticationError.custom(errorMessage: "No Medusa URL Stored")
        }

        guard let url = URL(string: urlString) else {
			throw Authentication.AuthenticationError.custom(errorMessage: "Couldn’t parse stored URL, it’s probably malformed")
        }

        guard let token = server.token else {
			throw Authentication.AuthenticationError.custom(errorMessage: "No token available")
        }

        var request = URLRequest(url: url.appending(path: "/admin/sales-channels"))
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
		guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw Authentication.AuthenticationError.custom(errorMessage: "Couldnt connect to medusa") }
		
		guard let salesChannelResponse = try? JSONDecoder().decode(SalesChannelReponse.self, from: data) else {
			throw Authentication.AuthenticationError.custom(errorMessage: "Invalid Product Schema")
		}
		
		guard let salesChannels = salesChannelResponse.sales_channels else {
			throw Authentication.AuthenticationError.custom(errorMessage: "No Sales Channel")
		}
		
		return salesChannels
    }
}
