//
//  AVSpeechSynthesisVoiceGender.swift
//  Speak
//
//  Created by Jack Finnis on 20/01/2023.
//

import Foundation
import AVFoundation

extension AVSpeechSynthesisVoiceGender {
    var initial: String {
        switch self {
        case .male:
            return "M"
        case .female:
            return "F"
        default:
            return ""
        }
    }
}
