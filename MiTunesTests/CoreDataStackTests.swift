//
//  CoreDataStackTests.swift
//  MiTunesTests
//
//  Created by Neil Francis Ramirez Hipona on 11/17/24.
//

import CoreData
import Foundation
import XCTest

@testable import MiTunes

final class CoreDataStackTests: XCTestCase {
    lazy var persistentContainer: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        let container = NSPersistentContainer(name: CoreDataStack.persistentContainerName)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    func testInsertAndDelete_givenData_shouldInsertAndDelete() {
        let sut = makeSUT()

        let data = sampleData()
        let media = sut.createMedia(for: data)
        sut.insert(model: media)

        let collection = sut.fetchAllMedia()
        XCTAssertTrue(!collection.isEmpty)

        sut.delete(item: media)

        let emptyCollection = sut.fetchAllMedia()
        XCTAssertTrue(emptyCollection.isEmpty)
    }
}

private
extension CoreDataStackTests {
    func makeSUT() -> CoreDataStack {
        let container = NSPersistentContainer(name: CoreDataStack.persistentContainerName)
        return CoreDataStack(persistentContainer: container)
    }
}

private
extension CoreDataStackTests {
    static let mockTrackId: Int = 1437031362

    func sampleData() -> iTunesMedia {
        iTunesMedia(
            wrapperType: "track",
            kind: "feature-movie",
            collectionId: 1727602354,
            trackId: CoreDataStackTests.mockTrackId,
            artistName: "Bradley Cooper",
            collectionName: "The Bodyguard and A Star Is Born",
            trackName: "A Star Is Born (2018)",
            collectionCensoredName: "The Bodyguard and A Star Is Born",
            trackCensoredName: "A Star Is Born (2018)",
            collectionArtistId: 199257486,
            collectionArtistViewUrl: "https://itunes.apple.com/au/artist/warner-bros-entertainment-inc/199257486?uo=4",
            collectionViewUrl: "https://itunes.apple.com/au/movie/a-star-is-born-2018/id1437031362?uo=4",
            trackViewUrl: "https://itunes.apple.com/au/movie/a-star-is-born-2018/id1437031362?uo=4",
            previewUrl: "https://video-ssl.itunes.apple.com/itunes-assets/Video128/v4/6b/cd/60/6bcd60b0-73ce-1a9e-1bf8-d7bcc8d32c10/mzvf_2708740245690387686.640x356.h264lc.U.p.m4v",
            artworkUrl30: "https://is1-ssl.mzstatic.com/image/thumb/Video115/v4/a2/26/fd/a226fd77-c80b-5ee7-e40f-6a0222e1645d/pr_source.jpg/30x30bb.jpg",
            artworkUrl60: "https://is1-ssl.mzstatic.com/image/thumb/Video115/v4/a2/26/fd/a226fd77-c80b-5ee7-e40f-6a0222e1645d/pr_source.jpg/60x60bb.jpg",
            artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Video115/v4/a2/26/fd/a226fd77-c80b-5ee7-e40f-6a0222e1645d/pr_source.jpg/100x100bb.jpg",
            collectionPrice: 14.99,
            trackPrice: 14.99,
            trackRentalPrice: 4.99,
            collectionHdPrice: 14.99,
            trackHdPrice: 14.99,
            trackHdRentalPrice: 4.99,
            releaseDate: "2018-10-18T07:00:00Z",
            collectionExplicitness: "notExplicit",
            trackExplicitness: "notExplicit",
            trackCount: 2,
            trackNumber: 1,
            trackTimeMillis: 8148723,
            country: "AUS",
            currency: "AUD",
            primaryGenreName: "Romance",
            contentAdvisoryRating: "M",
            shortDescription: "Seasoned musician Jackson Maine (Bradley Cooper) discovers—and falls in love with—struggling artist",
            longDescription: "Seasoned musician Jackson Maine (Bradley Cooper) discovers—and falls in love with—struggling artist Ally (Lady Gaga). She has just about given up on her dream to make it big as a singer… until Jack coaxes her into the spotlight. But even as Ally’s career takes off, the personal side of their relationship is breaking down, as Jack fights an ongoing battle with his own internal demons.",
            hasITunesExtras: true
        )
    }
}
