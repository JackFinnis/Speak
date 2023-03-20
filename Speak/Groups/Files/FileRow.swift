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
    
    let url: URL
    
    var body: some View {
        Button {
            if filesVM.url == url {
                filesVM.stop()
            } else {
                filesVM.play(url: url)
            }
        } label: {
            HStack {
                Group {
                    if filesVM.url == url {
                        Image(systemName: "stop.fill")
                    } else {
                        Image(systemName: "play.fill")
                    }
                }
                .frame(width: 25)
                
                Text(url.name)
                    .foregroundColor(.primary)
            }
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
                filesVM.delete(url: url)
            } label: {
                Label("Delete File", systemImage: "trash")
            }
        }
        .confirmationDialog("This file will be deleted. This action cannot be undone.", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete File", role: .destructive) {
                filesVM.delete(url: url)
            }
        }
    }
}

struct FileRow_Previews: PreviewProvider {
    static var previews: some View {
        FileRow(url: URL(string: "bbc.com")!)
            .environmentObject(FilesVM())
    }
}
