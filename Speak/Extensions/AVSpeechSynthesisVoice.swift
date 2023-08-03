//
//  AVSpeechSynthesisVoice.swift
//  Speak
//
//  Created by Jack Finnis on 21/01/2023.
//

import Foundation
import AVFoundation

extension AVSpeechSynthesisVoice {
    var isNovelty: Bool {
        ["Albert", "Bad News", "Bahh", "Bells", "Boing", "Bubbles", "Cellos", "Good News", "Jester", "Organ", "Superstar", "Trinoids", "Whisper", "Wobble", "Zarvox"].contains(name)
    }
    
    var locale: Locale {
        Locale(identifier: language)
    }
    
    var firstName: String {
        String(name.split(separator: " ").first ?? "")
    }
}
