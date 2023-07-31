//
//  FilesVM.swift
//  Speak
//
//  Created by Jack Finnis on 22/01/2023.
//

import Foundation
import CoreData
import AVFoundation
import SwiftUI

@MainActor
class FilesVM: ObservableObject {
    // MARK: - Properties
    @Published var files = [File]()
    
    @Published var selectedFile: File?
    
    @Published var searchText = ""
    @Published var filteredFiles = [File]()
    
    @Published var voices = [AVSpeechSynthesisVoice]()
    
    @Published var showErrorAlert = false
    var error: SpeakError? { didSet {
        showErrorAlert = true
    }}
    
    // Persistence
    let container = NSPersistentCloudKitContainer(name: "Speak")
    func save() {
        try? container.viewContext.save()
    }
    
    // MARK: - Initialiser
    init() {
        fetchFiles()
    }
    
    // MARK: - Methods
    func fetchFiles() {
        container.loadPersistentStores { description, error in
            self.files = self.fetch(File.self)
        }
    }
    
    func fetch<T: NSManagedObject>(_ entity: T.Type) -> [T] {
        (try? self.container.viewContext.fetch(T.fetchRequest()) as? [T]) ?? []
    }
    
    func fetchVoices() {
        voices = AVSpeechSynthesisVoice.speechVoices().filter { voice in
            !voice.novelty &&
            voice.language.prefix(2) == AVSpeechSynthesisVoice.currentLanguageCode().prefix(2)
        }
    }
    
    func importFile(url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            error = .openFile
            return
        }
        
        let text: String
        do {
            text = try String(contentsOf: url)
            url.stopAccessingSecurityScopedResource()
        } catch {
            self.error = .readFile
            return
        }
        
        createFile(text: text)
    }
    
    func createFile(text: String = "") {
        let file = File(context: container.viewContext)
        file.name = "New File"
        file.text = text
        file.recentDate = .now
        save()
        selectedFile = file
    }
    
    func deleteFile(_ file: File) {
        container.viewContext.delete(file)
        files.removeAll(file)
        save()
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
