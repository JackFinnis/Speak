//
//  Locale.swift
//  Speak
//
//  Created by Jack Finnis on 03/08/2023.
//

import Foundation

extension Locale {
    var languageName: String {
        Self.current.localizedString(forLanguageCode: identifier) ?? ""
    }
    
    var countryName: String {
        Self.current.localizedString(forRegionCode: regionCode ?? "") ?? ""
    }
}
