//
//  SpeakVM.swift
//  Speak
//
//  Created by Jack Finnis on 20/01/2023.
//

import Foundation
import AVFoundation
import SwiftUI
import PDFKit

@MainActor
class SpeakVM: NSObject, ObservableObject {
    enum State {
        case speaking
        case paused
        case ended
    }
    
    // MARK: - Properties
    let file: File
    @Published var text = "" { didSet {
        textView?.text = text
    }}

    @Defaults("voiceId") var selectedVoiceId = ""
    @Published var voice: AVSpeechSynthesisVoice? { didSet {
        selectedVoiceId = voice?.identifier ?? selectedVoiceId
    }}
    @Defaults("rate") var rate = AVSpeechUtteranceDefaultSpeechRate { didSet {
        objectWillChange.send()
        refreshSpeaking()
    }}
    
    @Published var showVoicesView = false
    
    let synthesizer = AVSpeechSynthesizer()
    @Published var state = State.ended
    var remainingText: String? {
        guard file.currentIndex < text.count else { return nil }
        return String(text.suffix(text.count - Int(file.currentIndex)))
    }

    @Published var showErrorAlert = false
    @Published var error = SpeakError.openFile { didSet {
        showErrorAlert = true
    }}

    @Published var isEditing = false
    var textView: UITextView?
    
    // MARK: - Initialiser
    init(file: File) {
        self.file = file
        super.init()
        synthesizer.delegate = self
        text = file.text
        rate = rate
        voice = AVSpeechSynthesisVoice(identifier: selectedVoiceId)
    }
    
    // MARK: - Methods
    func getUtterance(_ string: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = voice
        utterance.rate = rate
        return utterance
    }

    @discardableResult func isVoiceSelected() -> Bool {
        guard voice != nil else {
            showVoicesView = true
            return false
        }
        return true
    }

    func refreshSpeaking() {
        if let remainingText {
            let utterance = getUtterance(remainingText)
            stopSpeaking()
            synthesizer.speak(utterance)
        }
    }

    func pauseSpeaking() {
        synthesizer.pauseSpeaking(at: .immediate)
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    func toggleSpeaking() {
        switch state {
        case .speaking:
            pauseSpeaking()
        case .paused:
            refreshSpeaking()
        case .ended:
            guard isVoiceSelected() else { return }
            synthesizer.speak(getUtterance(text))
        }
    }

    func saveFile() {
        if text != file.text {
            file.text = text
            file.recentDate = .now
            FilesVM.shared.save()
        }
    }
    
    func importFile(url: URL) {
        guard let textView else { return }
        guard url.startAccessingSecurityScopedResource() else {
            error = .openFile
            return
        }

        let newText: String
        
        if url.pathExtension == "pdf" {
            let document = PDFDocument(url: url)
            guard let string = document?.string else {
                self.error = .readFile
                return
            }
            newText = string
        } else {
            do {
                newText = try String(contentsOf: url)
                url.stopAccessingSecurityScopedResource()
            } catch {
                self.error = .readFile
                return
            }
        }

        if let selectedRange = textView.selectedTextRange {
            let offset = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
            let index = text.index(text.startIndex, offsetBy: offset)
            text.insert(contentsOf: newText, at: index)
        } else {
            text.append(contentsOf: newText)
        }
    }

    func exportFile() {
        guard isVoiceSelected() else { return }
        guard let folder = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        else {
            error = .createFile
            return
        }
        let url = folder.appendingPathComponent(file.name).appendingPathExtension("caf")

        guard var components = URLComponents(string: url.absoluteString) else {
            error = .createFile
            return
        }
        components.scheme = "shareddocuments"
        guard let url = components.url else {
            error = .createFile
            return
        }

        synthesizer.write(getUtterance(text)) { buffer in
            guard let buffer = buffer as? AVAudioPCMBuffer else {
                self.error = .exportFile
                return
            }

            let file: AVAudioFile
            do {
                file = try AVAudioFile(forWriting: url, settings: buffer.format.settings, commonFormat: buffer.format.commonFormat, interleaved: buffer.format.isInterleaved)
            } catch {
                self.error = .createFile
                return
            }

            do {
                try file.write(from: buffer)
            } catch {
                self.error = .writeFile
                return
            }

            UIApplication.shared.open(url)
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension SpeakVM: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        if let range = Range(characterRange, in: utterance.speechString) {
            file.currentIndex = text.distance(from: text.startIndex, to: range.lowerBound)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        state = .ended
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        state = .ended
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        state = .paused
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        state = .speaking
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        state = .speaking
    }
}

// MARK: - UITextViewDelegate
extension SpeakVM: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        text = textView.text
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        isEditing = true
        pauseSpeaking()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        isEditing = false
        saveFile()
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
