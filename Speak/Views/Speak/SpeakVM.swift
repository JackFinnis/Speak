//
//  SpeakVM.swift
//  Speak
//
//  Created by Jack Finnis on 20/01/2023.
//

import Foundation
import AVFoundation
import SwiftUI

class SpeakVM: NSObject, ObservableObject {
    // MARK: - Properties
    let file: File
    @Published var text = ""
    @Published var name = ""
    
    @Defaults("selectedVoiceId") var selectedVoiceId = ""
    @Published var selectedVoice: AVSpeechSynthesisVoice? { didSet {
        selectedVoiceId = selectedVoice?.identifier ?? selectedVoiceId
        refresh()
    }}
    @Defaults("speakingRate") var speakingRate = AVSpeechUtteranceDefaultSpeechRate
    @Published var rate = AVSpeechUtteranceDefaultSpeechRate { didSet {
        speakingRate = rate
        refresh()
    }}
    
    @Published var showVoicesView = false
    
    @Published var isEditing = false
    @Published var isPaused = false
    @Published var isSpeaking = false
    var isResuming = false
    
    @Published var currentSpeakingRange: NSRange?
    let synthesizer = AVSpeechSynthesizer()
    
    var textView: UITextView?
    
    // MARK: - Initialiser
    init(file: File) {
        self.file = file
        super.init()
        text = file.text
        name = file.name
        synthesizer.delegate = self
        rate = speakingRate
        selectedVoice = AVSpeechSynthesisVoice(identifier: selectedVoiceId)
    }
    
    func start() {
        guard let selectedVoice else {
            showVoicesView = true
            return
        }
        speak()
    }
    
    func pause() {
        synthesizer.pauseSpeaking(at: .immediate)
    }
    
    func resume() {
        isResuming = true
        stop()
        speak()
    }
    
    func speak() {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = selectedVoice
        utterance.rate = rate
        synthesizer.speak(utterance)
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    func refresh() {
        if isSpeaking && !isPaused {
            resume()
        }
    }
    
    @objc
    func clearText() {
        text = ""
    }
    
    @objc
    func stopEditing() {
        textView?.resignFirstResponder()
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension SpeakVM: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        currentSpeakingRange = characterRange
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
        isResuming = false
        isPaused = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        isPaused = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if !isResuming {
            isPaused = false
            isSpeaking = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isPaused = false
        isSpeaking = false
    }
}

// MARK: - UITextViewDelegate
extension SpeakVM: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        text = textView.text
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.isEditing = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.isEditing = false
    }
}
