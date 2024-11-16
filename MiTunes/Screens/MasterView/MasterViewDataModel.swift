//
//  MasterViewDataModel.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/15/24.
//
// https://developer.apple.com/documentation/uikit/uicollectionviewdiffabledatasource
// https://developer.apple.com/documentation/uikit/nsdiffabledatasourcesnapshot

import Combine
import CoreData
import Foundation
import UIKit

// MARK: - Master Data

enum MasterViewSectionType: CaseIterable {
    case main
}

enum MasterViewModelItemAction {
    case favorite(_ media: Media)
}

struct MasterViewModelItem: Hashable {
    typealias UpdateNotifier = PassthroughSubject<MasterViewModelItemAction, Never>

    let id: String
    let sectionType: MasterViewSectionType
    let media: Media
    let updateNotifier = UpdateNotifier()

    init(
        id: String = UUID().uuidString,
        sectionType: MasterViewSectionType,
        media: Media
    ) {
        self.id = id
        self.sectionType = sectionType
        self.media = media
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MasterViewModelItem, rhs: MasterViewModelItem) -> Bool {
        lhs.id == rhs.id
    }
}

typealias MasterViewDataSource = UICollectionViewDiffableDataSource<MasterViewSectionType, MasterViewModelItem>
typealias MasterViewSnapshot = NSDiffableDataSourceSnapshot<MasterViewSectionType, MasterViewModelItem>

// MARK: - Favorite Data

struct MasterViewModelFavoriteItem: Hashable {
    let id: String
    let media: Media

    init(
        id: String = UUID().uuidString,
        media: Media
    ) {
        self.id = id
        self.media = media
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MasterViewModelFavoriteItem, rhs: MasterViewModelFavoriteItem) -> Bool {
        lhs.id == rhs.id
    }
}

typealias MasterViewFavoriteDataSource = UICollectionViewDiffableDataSource<Int, MasterViewModelFavoriteItem>
typealias MasterViewFavoriteSnapshot = NSDiffableDataSourceSnapshot<Int, MasterViewModelFavoriteItem>
