//
//  Optional+Ext.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import Foundation

// MARK: - Protocol

protocol Defaultable {
    static var defaultValue: Self { get }
}

// MARK: - Define Supported Optionals

extension Optional where Wrapped: Defaultable {
    var unwrapped: Wrapped { self ?? Wrapped.defaultValue }
}

extension String: Defaultable {
    static var defaultValue: String { "" }
}

extension Double: Defaultable {
    static var defaultValue: Double { 0.0 }
}

extension Int: Defaultable {
    static var defaultValue: Int { 0 }
}

extension Int64: Defaultable {
    static var defaultValue: Int64 { 0 }
}

extension Bool: Defaultable {
    static var defaultValue: Bool { false }
}

extension Dictionary: Defaultable {
    static var defaultValue: Dictionary { [:] }
}

extension Array: Defaultable {
    static var defaultValue: Array<Element> { [] }
}

extension AppConfiguration.Environment: Defaultable {
    static var defaultValue: AppConfiguration.Environment { .development }
}
