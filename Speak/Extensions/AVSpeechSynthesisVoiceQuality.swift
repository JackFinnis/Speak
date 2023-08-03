//
//  AVSpeechSynthesisVoiceQuality.swift
//  Speak
//
//  Created by Jack Finnis on 20/01/2023.
//

import Foundation
import AVFoundation

extension AVSpeechSynthesisVoiceQuality {
    var name: String {
        switch self {
        case .default:
            return "Default"
        case .enhanced:
            return "Enhanced"
        case .premium:
            return "Premium"
        @unknown default:
            return "Other"
        }
    }
}
