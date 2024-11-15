//
//  Constants.swift
//  MiTunes
//
//  Created by Neil Francis Ramirez Hipona on 11/15/24.
//

import Foundation

let currenyFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    numberFormatter.locale = Locale(identifier: "en_US")
    return numberFormatter
}()
