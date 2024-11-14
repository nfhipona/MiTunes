//
//  CoreDataStack+Media.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import Foundation

extension CoreDataStack {
    func createMedia(
        for model: iTunesMedia,
        isFavorite: Bool = false
    ) -> Media {
        let media = Media(context: viewContext)
        media.wrapperType = model.wrapperType
        media.kind = model.kind
        media.collectionId = model.collectionId.unwrapped.toInt16()
        media.trackId = model.trackId.toInt16()
        media.artistName = model.artistName
        media.collectionName = model.collectionName
        media.trackName = model.trackName
        media.collectionCensoredName = model.collectionCensoredName
        media.trackCensoredName = model.trackCensoredName
        media.collectionArtistId = model.collectionArtistId.unwrapped.toInt16()
        media.collectionArtistViewUrl = model.collectionArtistViewUrl
        media.collectionViewUrl = model.collectionViewUrl
        media.trackViewUrl = model.trackViewUrl
        media.previewUrl = model.previewUrl
        media.artworkUrl30 = model.artworkUrl30
        media.artworkUrl60 = model.artworkUrl60
        media.artworkUrl100 = model.artworkUrl100
        media.collectionPrice = model.collectionPrice
        media.trackPrice = model.trackPrice
        media.trackRentalPrice = model.trackRentalPrice.unwrapped
        media.collectionHdPrice = model.collectionHdPrice.unwrapped
        media.trackHdPrice = model.trackHdPrice.unwrapped
        media.trackHdRentalPrice = model.trackHdRentalPrice.unwrapped
        media.releaseDate = model.releaseDate
        media.collectionExplicitness = model.collectionExplicitness
        media.trackExplicitness = model.trackExplicitness
        media.trackCount = model.trackCount.unwrapped.toInt16()
        media.trackNumber = model.trackNumber.unwrapped.toInt16()
        media.trackTimeMillis = model.trackTimeMillis.toInt16()
        media.country = model.country
        media.currency = model.currency
        media.primaryGenreName = model.primaryGenreName
        media.contentAdvisoryRating = model.contentAdvisoryRating
        media.mediaShortDescription = model.shortDescription
        media.mediaLongDescription = model.longDescription
        media.hasITunesExtras = model.hasITunesExtras.unwrapped
        media.isFavorite = isFavorite
        return media
    }
}
