//
//  VoicesVM.swift
//  Speak
//
//  Created by Jack Finnis on 20/01/2023.
//

import Foundation
import AVFoundation

class VoicesVM: ObservableObject {
    let synthesizer = AVSpeechSynthesizer()
    
    func greet(voice: AVSpeechSynthesisVoice) {
        stopSpeaking()
        let greeting = "Hello, my name is \(voice.firstName). I am a \(voice.locale.languageName) voice from \(voice.locale.countryName)"
        let utterance = AVSpeechUtterance(string: greeting)
        utterance.voice = voice
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
