//
//  MiTunesTests.swift
//  MiTunesTests
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import Combine
import XCTest
@testable import MiTunes

final class MiTunesTests: XCTestCase {
    var iTunesAPI: iTunesServiceAPI!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        iTunesAPI = iTunesServiceAPI(
            service: MiTunesAPI(
                session: URLSession(configuration: configuration),
                baseURL: AppConfiguration.shared.baseURL
            )
        )
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        iTunesAPI = nil
        cancellables.removeAll()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        let expectation = expectation(description: "Mock request")

        MockURLProtocol.responseHandler = { request in
            guard
                let url = URL(string: "\(AppConfiguration.shared.baseURL)"),
                let response = HTTPURLResponse(
                    url: url,
                    statusCode: 200,
                    httpVersion: AppConfiguration.shared.version,
                    headerFields: [:]
                ), let data = self.mockResponseData
            else {
                return .error(code: -999, userInfo: ["message": "Unable load data"])
            }

            return .success(
                response: response, 
                data: data
            )
        }

        iTunesAPI
            .search(
                req: .search(queries: [:])
            )
            .sink { result in
                switch result {
                case .finished: break
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
                expectation.fulfill()
            } receiveValue: { result in
                XCTAssertEqual(1, result.resultCount)

                if let media = result.results.first {
                    XCTAssertEqual(1437031362, media.trackId)
                } else {
                    XCTFail("Expecting response")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5)
    }
}

private
extension MiTunesTests {
    var mockResponseData: Data? {
        """
        {
            "resultCount": 1,
            "results": [
                {
                    "wrapperType": "track",
                    "kind": "feature-movie",
                    "collectionId": 1727602354,
                    "trackId": 1437031362,
                    "artistName": "Bradley Cooper",
                    "collectionName": "The Bodyguard and A Star Is Born",
                    "trackName": "A Star Is Born (2018)",
                    "collectionCensoredName": "The Bodyguard and A Star Is Born",
                    "trackCensoredName": "A Star Is Born (2018)",
                    "collectionArtistId": 199257486,
                    "collectionArtistViewUrl": "https://itunes.apple.com/au/artist/warner-bros-entertainment-inc/199257486?uo=4",
                    "collectionViewUrl": "https://itunes.apple.com/au/movie/a-star-is-born-2018/id1437031362?uo=4",
                    "trackViewUrl": "https://itunes.apple.com/au/movie/a-star-is-born-2018/id1437031362?uo=4",
                    "previewUrl": "https://video-ssl.itunes.apple.com/itunes-assets/Video128/v4/6b/cd/60/6bcd60b0-73ce-1a9e-1bf8-d7bcc8d32c10/mzvf_2708740245690387686.640x356.h264lc.U.p.m4v",
                    "artworkUrl30": "https://is1-ssl.mzstatic.com/image/thumb/Video115/v4/a2/26/fd/a226fd77-c80b-5ee7-e40f-6a0222e1645d/pr_source.jpg/30x30bb.jpg",
                    "artworkUrl60": "https://is1-ssl.mzstatic.com/image/thumb/Video115/v4/a2/26/fd/a226fd77-c80b-5ee7-e40f-6a0222e1645d/pr_source.jpg/60x60bb.jpg",
                    "artworkUrl100": "https://is1-ssl.mzstatic.com/image/thumb/Video115/v4/a2/26/fd/a226fd77-c80b-5ee7-e40f-6a0222e1645d/pr_source.jpg/100x100bb.jpg",
                    "collectionPrice": 14.99,
                    "trackPrice": 14.99,
                    "trackRentalPrice": 4.99,
                    "collectionHdPrice": 14.99,
                    "trackHdPrice": 14.99,
                    "trackHdRentalPrice": 4.99,
                    "releaseDate": "2018-10-18T07:00:00Z",
                    "collectionExplicitness": "notExplicit",
                    "trackExplicitness": "notExplicit",
                    "trackCount": 2,
                    "trackNumber": 1,
                    "trackTimeMillis": 8148723,
                    "country": "AUS",
                    "currency": "AUD",
                    "primaryGenreName": "Romance",
                    "contentAdvisoryRating": "M",
                    "shortDescription": "Seasoned musician Jackson Maine (Bradley Cooper) discovers—and falls in love with—struggling artist",
                    "longDescription": "Seasoned musician Jackson Maine (Bradley Cooper) discovers—and falls in love with—struggling artist Ally (Lady Gaga). She has just about given up on her dream to make it big as a singer… until Jack coaxes her into the spotlight. But even as Ally’s career takes off, the personal side of their relationship is breaking down, as Jack fights an ongoing battle with his own internal demons.",
                    "hasITunesExtras": true
                }
            ]
        }
        """.data(using: .utf8)
    }
}
