//
//  SpeakVM.swift
//  Speak
//
//  Created by Jack Finnis on 20/01/2023.
//

import Foundation
import AVFoundation
import UIKit

class SpeakVM: NSObject, ObservableObject {
    let synthesizer = AVSpeechSynthesizer()
    var string = ""
    
    @Published var text: String
    @Defaults("voiceID") var voiceID = ""
    @Published var voice: AVSpeechSynthesisVoice? { didSet {
        voiceID = voice?.identifier ?? voiceID
        refresh()
    }}
    @Defaults("speakingRate") var speakingRate = AVSpeechUtteranceDefaultSpeechRate
    @Published var rate = AVSpeechUtteranceDefaultSpeechRate { didSet {
        speakingRate = rate
        refresh()
    }}
    
    @Published var showVoicesView = false
    
    @Published var paused = false
    @Published var speaking = false
    var resuming = false
    
    init(text: String) {
        self.text = text
        super.init()
        rate = speakingRate
        voice = AVSpeechSynthesisVoice(identifier: voiceID)
        synthesizer.delegate = self
    }
    
    func utterance(_ string: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = voice
        utterance.rate = rate
        return utterance
    }
    
    func start() {
        guard voice != nil else {
            showVoicesView = true
            return
        }
        string = text
        speak()
    }
    
    func pause() {
        synthesizer.pauseSpeaking(at: .immediate)
    }
    
    func resume() {
        resuming = true
        stop()
        speak()
    }
    
    func speak() {
        synthesizer.speak(utterance(string))
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    func refresh() {
        if speaking && !paused {
            resume()
        }
    }
    
    func export(name: String, completion: @escaping (Bool) -> Void) {
        synthesizer.write(utterance(text)) { buffer in
            guard let buffer = buffer as? AVAudioPCMBuffer,
                  let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            else { return }
            
            do {
                let url = path.appendingPathComponent("\(name).caf")
                let file = try AVAudioFile(forWriting: url, settings: buffer.format.settings, commonFormat: buffer.format.commonFormat, interleaved: buffer.format.isInterleaved)
                try file.write(from: buffer)
                completion(true)
            } catch {
                debugPrint(error)
                completion(false)
            }
        }
    }
}

extension SpeakVM: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        string = String(utterance.speechString.dropFirst(characterRange.location))
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        speaking = true
        resuming = false
        paused = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        paused = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if !resuming {
            paused = false
            speaking = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        paused = false
        speaking = false
    }
}
