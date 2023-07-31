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
    
    let file: File
    
    var body: some View {
        Button(file.name) {
            filesVM.selectedFile = file
        }
        .swipeActions {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                filesVM.deleteFile(file)
            } label: {
                Label("Delete File", systemImage: "trash")
            }
        }
        .confirmationDialog("This file will be deleted. This action cannot be undone.", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete File", role: .destructive) {
                filesVM.deleteFile(file)
            }
        }
    }
}
