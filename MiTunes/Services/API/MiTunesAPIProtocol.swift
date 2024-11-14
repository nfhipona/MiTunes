//
//  MiTunesAPIProtocol.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/14/24.
//

import Foundation

protocol MiTunesAPIProtocol {
    var method: MiTunesAPI.Method { get }
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
    var headers: [MiTunesAPI.Header]? { get }
}
