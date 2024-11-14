//
//  Utils+Ext.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import Foundation

// MARK: - Collection

extension [String: Any] {
    /// Usage: collection[.DEFINED_KEY]
    subscript(key: AppConfiguration.ConfigurationKey) -> Any? {
        self[key.rawValue]
    }
}
