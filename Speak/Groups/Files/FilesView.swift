//
//  FilesView.swift
//  Speak
//
//  Created by Jack Finnis on 22/01/2023.
//

import SwiftUI
import AVFoundation

struct FilesView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) var dismiss
    @StateObject var filesVM = FilesVM()
    @State var showPDFImporter = false
    @State var showURLPicker = false
    @State var pickerSourceType: UIImagePickerController.SourceType?
    
    @State var text = ""
    var filteredUrls: [URL] {
        filesVM.urls.filter { text.isEmpty || $0.name.localizedCaseInsensitiveContains(text) }
    }
    
    var body: some View {
        NavigationView {
            List(filteredUrls, id: \.self) { url in
                FileRow(url: url)
            }
            .animation(.default, value: filesVM.urls)
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $text.animation(), placement: .navigationBarDrawer(displayMode: .always))
            .onDisappear {
                filesVM.stop()
            }
        }
        .overlay {
            if filesVM.urls.isEmpty {
                ErrorLabel(systemName: "folder", title: "No Files Yet", message: "Tap the + at the bottom right to create a new file")
                    .padding(.horizontal)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Menu {
                Button {
                    showURLPicker = true
                } label: {
                    Label("Webpage", systemImage: "safari")
                }
                Button {
                    pickerSourceType = .photoLibrary
                } label: {
                    Label("Choose Photo", systemImage: "photo")
                }
                Button {
                    pickerSourceType = .camera
                } label: {
                    Label("Take Photo", systemImage: "camera")
                }
                Button {
                    showPDFImporter = true
                } label: {
                    Label("Import File", systemImage: "doc")
                }
                Button {
                    filesVM.showSpeakView = true
                } label: {
                    Label("Text", systemImage: "character.cursor.ibeam")
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24).bold())
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .padding()
            }
        }
        .sheet(isPresented: $filesVM.showSpeakView) {
            SpeakView(speakVM: SpeakVM(text: filesVM.text))
        }
        .sheet(item: $pickerSourceType) { type in
            ImagePicker(sourceType: type) { uiImage in
                filesVM.importImage(uiImage)
            }
        }
        .sheet(isPresented: $showURLPicker) {
            URLPicker { url in
                Task {
                    await filesVM.importWebpage(url)
                }
            }
        }
        .fileImporter(isPresented: $showPDFImporter, allowedContentTypes: [.pdf, .text]) { result in
            switch result {
            case .success(let url):
                filesVM.importFile(from: url)
            case .failure(let error):
                debugPrint(error)
            }
        }
        .navigationViewStyle(.stack)
        .onChange(of: scenePhase) { newPhase in
            if scenePhase == .active {
                filesVM.fetchVoices()
            }
        }
        .environmentObject(filesVM)
    }
}

struct FilesView_Previews: PreviewProvider {
    static var previews: some View {
        FilesView()
    }
}
