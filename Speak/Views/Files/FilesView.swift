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
    @StateObject var filesVM = FilesVM.shared
    @State var isEditing = false
    
    var body: some View {
        NavigationView {
            List {
                ListBuffer(isPresented: filesVM.filteredFiles.isEmpty)
                ForEach(filesVM.filteredFiles) { file in
                    FileRow(isEditing: $isEditing, file: file)
                }
                .onDelete { offsets in
                    filesVM.deleteFiles(at: offsets)
                }
            }
            .animation(.default, value: filesVM.filteredFiles)
            .navigationTitle("Files")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $filesVM.searchText.animation(), placement: .navigationBarDrawer(displayMode: .always))
            .background {
                NavigationLink("", isActive: $filesVM.showSpeakView) {
                    if let file = filesVM.selectedFile {
                        SpeakView(speakVM: SpeakVM(file: file))
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if !isEditing {
                    Button {
                        filesVM.createFile()
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
            }
        }
        .overlay {
            if filesVM.files.isEmpty {
                BigLabel(systemName: "person.wave.2.fill", title: "No Files Yet", message: "Tap the + at the bottom right\nto make a new file.")
            } else if filesVM.filteredFiles.isEmpty {
                Text("No Results Found")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if scenePhase == .active {
                filesVM.fetchVoices()
            }
        }
        .navigationViewStyle(.stack)
        .environmentObject(filesVM)
        .animation(.default, value: isEditing)
    }
}

struct FilesView_Previews: PreviewProvider {
    static var previews: some View {
        FilesView()
    }
}
