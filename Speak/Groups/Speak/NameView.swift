//
//  NameView.swift
//  Speak
//
//  Created by Jack Finnis on 22/01/2023.
//

import SwiftUI

struct NameView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var speakVM: SpeakVM
    @EnvironmentObject var filesVM: FilesVM
    @FocusState var focused: Bool
    @State var name = ""
    @State var taken = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("File Name", text: $name)
                        .submitLabel(.done)
                        .focused($focused)
                        .overlay(alignment: .trailing) {
                            if name.isNotEmpty && focused {
                                ClearCross()
                            }
                        }
                } footer: {
                    if taken {
                        Text("This name has been taken. Please choose a different name.")
                    }
                }
            }
            .navigationTitle("Save File")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                focused = true
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        let trimmed = name.trimmed
                        taken = filesVM.nameTaken(trimmed)
                        if !taken {
                            speakVM.export(name: trimmed) { success in
                                if success {
                                    dismiss()
                                    filesVM.showSpeakView = false
                                    filesVM.fetchFiles()
                                }
                            }
                        }
                    }
                    .font(.headline)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct NameView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true)) {
                NameView(speakVM: SpeakVM(text: ""))
            }
    }
}
