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

class FilesVM: ObservableObject {
    @Published var urls = [URL]()
    @Published var voices = [AVSpeechSynthesisVoice]()
    @Published var text = ""
    @Published var showSpeakView = false
    
    init() {
        fetchFiles()
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
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            self.text = observations.compactMap { $0.topCandidates(1).first?.string }.joined()
            self.showSpeakView = true
        }
        request.recognitionLevel = .accurate
        try? handler.perform([request])
    }
    
    func importWebpage(_ url: URL) {
        if let string = try? String(contentsOf: url) {
            text = string
            showSpeakView = true
        }
    }
}
