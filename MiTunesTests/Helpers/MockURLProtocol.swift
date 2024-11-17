//
//  MockURLProtocol.swift
//  MiTunesTests
//
//  Created by Neil Francis Ramirez Hipona on 11/17/24.
//

import Foundation

final class MockURLProtocol: URLProtocol {
    typealias MockRequestHandler = (_ request: URLRequest) -> RequestType

    enum RequestType {
        case success(response: HTTPURLResponse, data: Data)
        case error(code: Int, userInfo: [String: Any]?)
    }

    static var responseHandler: MockRequestHandler?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let client, let handler = MockURLProtocol.responseHandler
        else {
            client?.urlProtocol(
                self,
                didFailWithError: NSError(
                    domain: AppConfiguration.shared.bundleIdentifier,
                    code: -9999
                )
            )
            return
        }

        let type = handler(request)
        switch type {
        case let .success(response, data):
            client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client.urlProtocol(self, didLoad: data)
            client.urlProtocolDidFinishLoading(self)
        case let .error(code, userInfo):
            client.urlProtocol(self, didFailWithError: NSError(
                domain: AppConfiguration.shared.bundleIdentifier,
                code: code,
                userInfo: userInfo
            ))
        }
    }

    override func stopLoading() { }
}
