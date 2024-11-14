//
//  MiTunesAPI.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import Foundation
import Combine

extension MiTunesAPI {
    enum APIError: Error {
        case unableToComplete
        case invalidURL
    }

    enum Method: String {
        case get = "GET"
    }

    struct Header {
        let name: String
        let value: String
    }
}

final class MiTunesAPI {
    let baseURL: String
    let decoder: JSONDecoder

    static let shared = MiTunesAPI(
        baseURL: AppConfiguration.shared.baseURL
    )

    init(baseURL: String) {
        self.baseURL = baseURL
        self.decoder = JSONDecoder()
    }

    func request<T: Decodable>(
        path: String,
        method: Method = .get,
        headers: [Header]? = nil,
        body: Data? = nil,
        queryItems: [URLQueryItem]? = nil
    ) -> AnyPublisher<T, Error> {
        guard 
            var components = URLComponents(string: baseURL.appending(path)),
            let url = components.url
        else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        components.queryItems = queryItems

        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 120
        )
        request.httpMethod = method.rawValue
        request.httpBody = body

        headers
            .unwrapped
            .forEach {
                request.setValue($0.value, forHTTPHeaderField: $0.name)
            }

        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
