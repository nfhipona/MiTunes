//
//  AppConfiguration.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import Foundation

final class AppConfiguration {
    static let shared = AppConfiguration()

    let environment: String
    let bundleName: String
    let bundleIdentifier: String
    let version: String
    let build: String
    let baseURL: String

    init() {
        let infoDictionary = Bundle.main.infoDictionary.unwrapped
        environment = (infoDictionary[.environment] as? String).unwrapped
        bundleName = (infoDictionary[.bundleName] as? String).unwrapped
        bundleIdentifier = (infoDictionary[.bundleIdentifier] as? String).unwrapped
        version = (infoDictionary[.version] as? String).unwrapped
        build = (infoDictionary[.build] as? String).unwrapped
        baseURL = (infoDictionary[.baseURL] as? String).unwrapped
    }

    func log() {
        print(
            """
            \n
                Environment: \(environment)
                Bundle Name: \(bundleName)
                Bundle Identifier: \(bundleIdentifier)
                Version: \(version)
                Build: \(build)
                Base URL: \(baseURL)
            \n
            """
        )
    }
}

extension AppConfiguration {
    enum ConfigurationKey: String {
        case environment = "App Environment"
        case bundleName = "CFBundleDisplayName"
        case bundleIdentifier = "CFBundleIdentifier"
        case version = "CFBundleShortVersionString"
        case build = "CFBundleVersion"
        case baseURL = "Base URL"
    }
}
