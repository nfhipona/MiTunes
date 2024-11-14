//
//  iTunesSearchResult.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import Foundation

struct iTunesSearchResult: Decodable {
    let resultCount: Int
    let results: [iTunesMedia]

    enum CodingKeys: CodingKey {
        case resultCount
        case results
    }
}
