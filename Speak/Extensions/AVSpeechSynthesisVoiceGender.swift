//
//  AVSpeechSynthesisVoiceGender.swift
//  Speak
//
//  Created by Jack Finnis on 20/01/2023.
//

import Foundation
import AVFoundation

extension AVSpeechSynthesisVoiceGender {
    static let allCases = [AVSpeechSynthesisVoiceGender.male, .female, .unspecified]
    
    var name: String {
        switch self {
        case .unspecified:
            return "Other"
        case .male:
            return "Male"
        case .female:
            return "Female"
        @unknown default:
            return "Other"
        }
    }
    
    var initial: String {
        switch self {
        case .unspecified:
            return ""
        case .male:
            return "M"
        case .female:
            return "F"
        @unknown default:
            return ""
        }
    }
}
