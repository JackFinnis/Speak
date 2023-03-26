//
//  FilesVM.swift
//  Speak
//
//  Created by Jack Finnis on 22/01/2023.
//

import Foundation
import AVFoundation
import PDFKit
import Vision
import SwiftSoup

@MainActor
class FilesVM: NSObject, ObservableObject {
    @Published var urls = [URL]()
    @Published var voices = [AVSpeechSynthesisVoice]()
    @Published var text = ""
    @Published var showSpeakView = false
    @Published var player: AVAudioPlayer?
    @Published var url: URL?
    
    override init() {
        super.init()
        fetchFiles()
        fetchVoices()
        startAudioSession()
    }
    
    func startAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func fetchFiles() {
        guard let path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return }
        urls = (try? FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)) ?? []
    }
    
    func nameTaken(_ name: String) -> Bool {
        return urls.map(\.name).contains(name)
    }
    
    func fetchVoices() {
        voices = AVSpeechSynthesisVoice.speechVoices().filter { voice in
            !voice.novelty &&
            voice.language.prefix(2) == AVSpeechSynthesisVoice.currentLanguageCode().prefix(2)
        }
    }
    
    func importFile(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        if let pdf = PDFDocument(url: url) {
            for i in 0..<pdf.pageCount {
                guard let page = pdf.page(at: i),
                      let string = page.attributedString?.string
                else { continue }
                text.append(string)
            }
        } else if let string = try? String(contentsOf: url) {
            text = string
        }
        showSpeakView = text.isNotEmpty
        url.stopAccessingSecurityScopedResource()
    }
    
    func importImage(_ uiImage: UIImage?) {
        guard let cgImage = uiImage?.cgImage else { return }
        let handler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], observations.isNotEmpty else { return }
            self.text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")
            self.showSpeakView = true
        }
        request.recognitionLevel = .accurate
        try? handler.perform([request])
    }
    
    func importWebpage(_ url: URL) async {
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let html = String(data: data, encoding: .utf8),
              let string = try? SwiftSoup.parse(html).text()
        else { return }
        
        text = string
        showSpeakView = true
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    func delete(url: URL) {
        try? FileManager.default.removeItem(at: url)
        fetchFiles()
        if self.url == url {
            stop()
        }
    }
    
    func play(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.volume = 1
            player?.play()
            self.url = url
        } catch {
            debugPrint(error)
        }
    }
    
    func stop() {
        player?.stop()
        url = nil
    }
}

extension FilesVM: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        url = nil
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        url = nil
    }
}
