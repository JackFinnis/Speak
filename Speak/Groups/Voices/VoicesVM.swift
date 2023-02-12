//
//  VoicesVM.swift
//  Speak
//
//  Created by Jack Finnis on 20/01/2023.
//

import Foundation
import AVFoundation

class VoicesVM: NSObject, ObservableObject {
    let synthesizer = AVSpeechSynthesizer()
    
    @Published var speaking: AVSpeechSynthesisVoice?
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func greet(voice: AVSpeechSynthesisVoice) {
        stop()
        let utterance = AVSpeechUtterance(string: "Hello, my name is \(voice.name). I am a \(voice.languageName) voice from \(voice.country)")
        utterance.voice = voice
        synthesizer.speak(utterance)
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

extension VoicesVM: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        speaking = utterance.voice
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speaking = nil
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        speaking = nil
    }
}
