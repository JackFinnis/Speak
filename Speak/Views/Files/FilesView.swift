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
    @StateObject var filesVM = FilesVM()
    @State var showFileImporter = false
    
    var body: some View {
        NavigationView {
            List(filesVM.filteredFiles, id: \.self) { file in
                FileRow(file: file)
            }
            .animation(.default, value: filesVM.files)
            .navigationTitle("Files")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $filesVM.searchText.animation(), placement: .navigationBarDrawer(displayMode: .always))
        }
        .overlay {
            if filesVM.files.isEmpty {
                BigLabel(systemName: "person.wave.2.fill", title: "No Recordings Yet", message: "Tap the + at the bottom right to\nmake a new recording.")
                    .padding(.horizontal)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Menu {
                Button {
                    showFileImporter = true
                } label: {
                    Label("Import File", systemImage: "doc")
                }
                Button {
                    filesVM.createFile()
                } label: {
                    Label("Type Text", systemImage: "character.cursor.ibeam")
                }
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .shadow()
            }
            .padding()
        }
        .sheet(item: $filesVM.selectedFile) { file in
            SpeakView(speakVM: SpeakVM(file: file))
        }
        .onChange(of: scenePhase) { newPhase in
            if scenePhase == .active {
                filesVM.fetchVoices()
            }
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.text]) { result in
            switch result {
            case .success(let url):
                filesVM.importFile(url: url)
            case .failure(let error):
                debugPrint(error)
            }
        }
        .navigationViewStyle(.stack)
        .environmentObject(filesVM)
    }
}

struct FilesView_Previews: PreviewProvider {
    static var previews: some View {
        FilesView()
    }
}
