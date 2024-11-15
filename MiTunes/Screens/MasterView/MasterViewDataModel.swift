//
//  MasterViewDataModel.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/15/24.
//
// https://developer.apple.com/documentation/uikit/uicollectionviewdiffabledatasource
// https://developer.apple.com/documentation/uikit/nsdiffabledatasourcesnapshot


import CoreData
import Foundation
import UIKit

enum MasterViewSectionType: CaseIterable {
    case main
}

struct MasterViewModelItem: Hashable {
    let id: String
    let sectionType: MasterViewSectionType
    let media: Media

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
