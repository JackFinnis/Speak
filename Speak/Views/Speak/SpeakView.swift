//
//  SpeakView.swift
//  Speak
//
//  Created by Jack Finnis on 20/01/2023.
//

import SwiftUI

struct SpeakView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var filesVM: FilesVM
    @StateObject var speakVM: SpeakVM
    @State var showFileImporter = false
    @State var name = ""
    
    var body: some View {
        TextView()
            .overlay(alignment: .topLeading) {
                if speakVM.text.isEmpty {
                    Text("Enter text here")
                        .padding(.top, 10)
                        .padding(.leading, 20)
                        .foregroundColor(Color(.placeholderText))
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !speakVM.isEditing {
                    SpeakBar()
                        .transition(.move(edge: .bottom))
                }
            }
            .animation(.default, value: speakVM.isEditing)
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                speakVM.stopSpeaking()
                if speakVM.text.isEmpty {
                    filesVM.deleteFile(speakVM.file)
                } else {
                    if !filesVM.files.contains(speakVM.file) {
                        filesVM.files.append(speakVM.file)
                    }
                    speakVM.saveFile()
                }
            }
            .if { view in
                if #available(iOS 16, *) {
                    view.navigationTitle($name)
                        .onAppear {
                            name = speakVM.file.name
                        }
                        .onChange(of: name) { newName in
                            speakVM.file.name = name
                            speakVM.saveFile()
                        }
                } else {
                    view.navigationTitle(speakVM.file.name)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showFileImporter = true
                        } label: {
                            Label("Import File", systemImage: "doc.text")
                        }
                        Button {
                            speakVM.exportFile()
                        } label: {
                            Label("Export File", systemImage: "square.and.arrow.up")
                        }
                        Button(role: .destructive) {
                            filesVM.deleteFile(speakVM.file)
                        } label: {
                            Label("Delete File", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                    }
                }
            }
            .background {
                Text("")
                    .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.text, .pdf]) { result in
                        switch result {
                        case .success(let url):
                            speakVM.importFile(url: url)
                        case .failure(let error):
                            debugPrint(error)
                        }
                    }
                Text("")
                    .sheet(isPresented: $speakVM.showVoicesView) {
                        VoicesView()
                    }
                Text("")
                    .alert(speakVM.error.title, isPresented: $speakVM.showErrorAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text(speakVM.error.description)
                    }
            }
            .environmentObject(speakVM)
    }
}

struct TextView: UIViewRepresentable {
    @EnvironmentObject var speakVM: SpeakVM
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = speakVM
        speakVM.textView = textView

        textView.text = speakVM.text
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        textView.textContainer.lineFragmentPadding = 0
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isSelectable = true

        let toolbar = UIToolbar()
        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: speakVM, action: #selector(SpeakVM.clearText))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let dismissButton = UIBarButtonItem(title: "Done", style: .done, target: speakVM, action: #selector(SpeakVM.stopEditing))
        toolbar.items = [clearButton, spacer, dismissButton]
        toolbar.sizeToFit()
        textView.inputAccessoryView = toolbar
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        textView.font = .systemFont(ofSize: UIFont.buttonFontSize)
    }
}
