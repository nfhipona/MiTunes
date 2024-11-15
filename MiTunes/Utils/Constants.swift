//
//  Constants.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/15/24.
//

import Foundation

let currenyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM d, yyyy hh:mm:ss a"
    formatter.locale = .current
    return formatter
}()
