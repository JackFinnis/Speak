//
//  SpeakView.swift
//  Speak
//
//  Created by Jack Finnis on 20/01/2023.
//

import SwiftUI

struct SpeakView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var speakVM: SpeakVM
    @FocusState var focused: Bool
    @State var showNameView = false
    @State var showDeleteConfirmation = false
    
    var empty: Bool { speakVM.text.trimmed.isEmpty }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextEditor(text: $speakVM.text)
                    .focused($focused)
                    .overlay(alignment: .topLeading) {
                        if speakVM.text.isEmpty {
                            Text("Enter text here")
                                .foregroundColor(Color(uiColor: .placeholderText))
                                .allowsHitTesting(false)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                    }
                    .padding(.horizontal)
                if !focused {
                    ActionBar(speakVM: speakVM)
                        .transition(.move(edge: .bottom))
                }
            }
            .animation(.default, value: focused)
            .navigationTitle("Speak")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(!empty)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if empty {
                            dismiss()
                        } else {
                            showDeleteConfirmation = true
                        }
                    }
                    .confirmationDialog("Delete Draft", isPresented: $showDeleteConfirmation) {
                        Button("Delete Draft", role: .destructive) {
                            dismiss()
                            speakVM.stop()
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        showNameView = true
                    }
                    .font(.headline)
                }
                ToolbarItem(placement: .keyboard) {
                    Row {
                        Button("Clear") {
                            speakVM.text = ""
                        }
                        .disabled(speakVM.text.isEmpty)
                    } trailing: {
                        Button("Done") {
                            focused = false
                        }
                        .font(.headline)
                    }
                }
            }
        }
        .sheet(isPresented: $speakVM.showVoicesView) {
            VoicesView(speakVM: speakVM)
        }
        .sheet(isPresented: $showNameView) {
            NameView(speakVM: speakVM)
        }
    }
}

struct SpeakView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true)) {
                SpeakView(speakVM: SpeakVM(text: ""))
            }
    }
}
