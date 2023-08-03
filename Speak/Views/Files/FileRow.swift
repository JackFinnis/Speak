//
//  FileRow.swift
//  Speak
//
//  Created by Jack Finnis on 25/01/2023.
//

import SwiftUI

struct FileRow: View {
    @EnvironmentObject var filesVM: FilesVM
    @State var showDeleteConfirmation = false
    @FocusState var focused: Bool
    @State var name = ""
    
    @Binding var isEditing: Bool
    let file: File
    
    var body: some View {
        if filesVM.files.contains(file) {
            Button {
                if isEditing {
                    focused = true
                } else {
                    filesVM.selectedFile = file
                }
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        TextField("Name", text: $name)
                            .font(.headline)
                            .focused($focused)
                            .submitLabel(.done)
                            .onSubmit(submitName)
                            .allowsHitTesting(isEditing)
                            .foregroundColor(.primary)
                            .onAppear {
                                name = file.name
                            }
                        Text(file.recentDate.formattedApple())
                            .foregroundColor(.secondary)
                        if !isEditing {
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(.placeholderText))
                                .font(.footnote.bold())
                        }
                    }
                    Text(file.text + "\n")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .lineLimit(2)
                }
                .padding(.vertical, 3)
            }
            .contextMenu {
                Button {
                    focused = true
                    isEditing = true
                } label: {
                    Label("Rename", systemImage: "pencil")
                }
                Button(role: .destructive) {
                    filesVM.deleteFile(file)
                } label: {
                    Label("Delete File", systemImage: "trash")
                }
            }
            .swipeActions {
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .tint(.red)
            }
            .confirmationDialog("This file will be deleted. This action cannot be undone.", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete File", role: .destructive) {
                    filesVM.deleteFile(file)
                }
            }
        }
    }
    
    func submitName() {
        isEditing = false
        if name.isEmpty {
            name = file.name
        } else {
            file.name = name
            filesVM.save()
        }
    }
}
