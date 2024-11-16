//
//  Utils+Ext.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import AlamofireImage
import Foundation
import UIKit

// MARK: - Collection

extension [String: Any] {
    /// Usage: collection[.DEFINED_KEY]
    subscript(key: AppConfiguration.ConfigurationKey) -> Any? {
        self[key.rawValue]
    }
}

// MARK: - Data Types

extension Int {
    /// Converts Int to Int16 data type
    func toInt16() -> Int16 {
        Int16(exactly: self).unwrapped
    }
}

// MARK: - UIView

extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }

    /// Sets translatesAutoresizingMaskIntoConstraints to false
    func translatesAutoresizingMask() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}

// MARK: - Double

extension Double {
    var currency: String {
        let number = NSNumber(value: self)
        return currenyFormatter.string(from: number) ?? "$0.0"
    }
}

// MARK: - Date

extension Date {
    var readableDisplay: String {
        dateFormatter.string(from: self)
    }
}

// MARK: - UIImageView

extension UIImageView {
    func setImageURL(_ url: String) {
        let placeholderImage = UIImage(systemName: "movieclapper.fill")?
            .withRenderingMode(.alwaysTemplate)
        placeholderImage?.withTintColor(.blue)

        if let imageURL = URL(string: url) {
            af.setImage(
                withURL: imageURL,
                placeholderImage: placeholderImage
            )
        } else {
            image = placeholderImage
        }
    }
}
