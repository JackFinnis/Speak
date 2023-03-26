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
    @State var showCamera = false
    @State var showPhotoLibrary = false
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
            .navigationTitle("Recordings")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $text.animation(), placement: .navigationBarDrawer(displayMode: .always))
            .onDisappear {
                filesVM.stop()
            }
        }
        .overlay {
            if filesVM.urls.isEmpty {
                BigLabel(systemName: "person.wave.2.fill", title: "No Recordings Yet", message: "Tap the + at the bottom right to\nmake a new recording.")
                    .padding(.horizontal)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Menu {
                Button {
                    showURLPicker = true
                } label: {
                    Label("Import Webpage", systemImage: "safari")
                }
                Button {
                    showPDFImporter = true
                } label: {
                    Label("Import File", systemImage: "doc")
                }
                Button {
                    showPhotoLibrary = true
                } label: {
                    Label("Choose Photo", systemImage: "photo")
                }
                Button {
                    showCamera = true
                } label: {
                    Label("Take Photo", systemImage: "camera")
                }
                Button {
                    filesVM.text = ""
                    filesVM.showSpeakView = true
                } label: {
                    Label("Type Text", systemImage: "character.cursor.ibeam")
                }
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .padding()
            }
        }
        .sheet(isPresented: $filesVM.showSpeakView) {
            SpeakView(speakVM: SpeakVM(text: filesVM.text))
        }
        .sheet(isPresented: $showPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary) { uiImage in
                filesVM.importImage(uiImage)
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { uiImage in
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
