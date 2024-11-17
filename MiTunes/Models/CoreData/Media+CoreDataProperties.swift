//
//  Media+CoreDataProperties.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/17/24.
//
//

import Foundation
import CoreData


extension Media {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Media> {
        return NSFetchRequest<Media>(entityName: "Media")
    }

    @NSManaged public var artistName: String?
    @NSManaged public var artworkUrl30: String?
    @NSManaged public var artworkUrl60: String?
    @NSManaged public var artworkUrl100: String?
    @NSManaged public var collectionArtistId: Int16
    @NSManaged public var collectionArtistViewUrl: String?
    @NSManaged public var collectionCensoredName: String?
    @NSManaged public var collectionExplicitness: String?
    @NSManaged public var collectionHdPrice: Double
    @NSManaged public var collectionId: Int16
    @NSManaged public var collectionName: String?
    @NSManaged public var collectionPrice: Double
    @NSManaged public var collectionViewUrl: String?
    @NSManaged public var contentAdvisoryRating: String?
    @NSManaged public var country: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var currency: String?
    @NSManaged public var hasITunesExtras: Bool
    @NSManaged public var isFavorite: Bool
    @NSManaged public var kind: String?
    @NSManaged public var lastVisitAt: Date?
    @NSManaged public var mediaLongDescription: String?
    @NSManaged public var mediaShortDescription: String?
    @NSManaged public var previewUrl: String?
    @NSManaged public var primaryGenreName: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var trackCensoredName: String?
    @NSManaged public var trackCount: Int16
    @NSManaged public var trackExplicitness: String?
    @NSManaged public var trackHdPrice: Double
    @NSManaged public var trackHdRentalPrice: Double
    @NSManaged public var trackId: Int16
    @NSManaged public var trackName: String?
    @NSManaged public var trackNumber: Int16
    @NSManaged public var trackPrice: Double
    @NSManaged public var trackRentalPrice: Double
    @NSManaged public var trackTimeMillis: Int16
    @NSManaged public var trackViewUrl: String?
    @NSManaged public var wrapperType: String?

}

extension Media : Identifiable {

}
