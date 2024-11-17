//
//  iTunesServiceAPI.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import Foundation
import Combine

enum iTunesService: MiTunesAPIProtocol {
    case search(queries: [String: String]?)

    var method: MiTunesAPI.Method {
        switch self {
        case .search:
            return .get
        }
    }

    var path: String {
        switch self {
        case .search:
            return "/search"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case let .search(queries):
            return queries.unwrapped.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
    }

    var body: Data? {
        return nil
    }

    var headers: [MiTunesAPI.Header]? {
        switch self {
        case .search:
            return [
                MiTunesAPI.acceptJSON,
                MiTunesAPI.contentTypeJSON
            ]
        }
    }
}

final class iTunesServiceAPI {
    typealias APIService = iTunesService

    private let service: MiTunesAPI

    init(
        service: MiTunesAPI = .shared
    ) {
        self.service = service
    }

    func search(req: APIService) -> AnyPublisher<iTunesSearchResult, Error> {
        service.request(
            path: req.path,
            method: req.method,
            headers: req.headers,
            body: req.body,
            queryItems: req.queryItems
        )
    }
}
