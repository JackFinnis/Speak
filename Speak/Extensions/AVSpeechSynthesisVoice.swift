//
//  AVSpeechSynthesisVoice.swift
//  Speak
//
//  Created by Jack Finnis on 21/01/2023.
//

import Foundation
import AVFoundation

extension AVSpeechSynthesisVoice {
    var novelty: Bool {
        ["Albert", "Bad News", "Bahh", "Bells", "Boing", "Bubbles", "Cellos", "Good News", "Jester", "Organ", "Superstar", "Trinoids", "Whisper", "Wobble", "Zarvox"].contains(name)
    }
    
    var languageName: String {
        return Locale.current.localizedString(forLanguageCode: language) ?? ""
    }
    
    var country: String {
        AVSpeechSynthesisVoice.getCountry(code: language)
    }
    
    static var country: String {
        getCountry(code: currentLanguageCode())
    }
    
    static func getCountry(code: String) -> String {
        let components = Locale.components(fromIdentifier: code)
        guard let code = components["kCFLocaleCountryCodeKey"] else { return "" }
        return Locale.current.localizedString(forRegionCode: code) ?? ""
    }
}
