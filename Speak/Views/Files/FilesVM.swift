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
    static let shared = FilesVM()
    
    // MARK: - Properties
    @Published var files = [File]()
    
    @Published var showSpeakView = false
    @Published var selectedFile: File? { didSet {
        showSpeakView = true
    }}
    
    @Published var filteredFiles = [File]()
    @Published var searchText = "" { didSet {
        filterFiles()
    }}
    
    @Published var voices = [AVSpeechSynthesisVoice]()
    
    // Storage
    @Storage("filesCreated") var filesCreated = 0
    
    // Persistence
    let container = NSPersistentCloudKitContainer(name: "Speak")
    func save() {
        try? container.viewContext.save()
        filterFiles()
    }
    
    // MARK: - Initialiser
    init() {
        fetchFiles()
        fetchVoices()
    }
    
    // MARK: - Methods
    func fetchFiles() {
        container.loadPersistentStores { description, error in
            self.files = self.fetch(File.self)
            self.filterFiles()
        }
    }
    
    func filterFiles() {
        filteredFiles = files.filter { file in
            searchText.isEmpty || file.name.localizedCaseInsensitiveContains(searchText)
        }
        .sorted { $0.recentDate > $1.recentDate }
    }
    
    func fetch<T: NSManagedObject>(_ entity: T.Type) -> [T] {
        (try? self.container.viewContext.fetch(T.fetchRequest()) as? [T]) ?? []
    }
    
    func fetchVoices() {
        voices = AVSpeechSynthesisVoice.speechVoices().filter { voice in
            !voice.isNovelty &&
            voice.locale.languageCode == Locale.current.languageCode
        }
    }
    
    func createFile() {
        filesCreated += 1
        let file = File(context: container.viewContext)
        file.name = "New File \(filesCreated)"
        file.text = ""
        file.recentDate = .now
        save()
        selectedFile = file
    }
    
    func deleteFile(_ file: File) {
        files.removeAll(file)
        container.viewContext.delete(file)
        save()
        showSpeakView = false
    }
    
    func deleteFiles(at offsets: IndexSet) {
        let files = offsets.map { filteredFiles[$0] }
        files.forEach(deleteFile)
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
