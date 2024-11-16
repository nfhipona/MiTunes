//
//  MiTunesAPI.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//
// https://developer.apple.com/documentation/foundation/urlsession/processing_url_session_data_task_results_with_combine

import Alamofire
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
    private let session: URLSession
    private let retry: Int
    private let baseURL: String
    private let decoder: JSONDecoder

    static let shared = MiTunesAPI(
        baseURL: AppConfiguration.shared.baseURL
    )

    init(
        session: URLSession = .shared,
        retry: Int = 3,
        baseURL: String
    ) {
        self.session = session
        self.retry = retry
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
        guard var components = URLComponents(string: baseURL.appending(path))
        else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        components.queryItems = queryItems
        guard let url = components.url
        else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

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

        return session
            .dataTaskPublisher(for: request)
            .retry(retry)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
