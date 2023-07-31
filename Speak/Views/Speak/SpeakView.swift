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
    
    var body: some View {
        NavigationView {
            TextView()
                .safeAreaInset(edge: .bottom) {
                    if !speakVM.isEditing {
                        SpeakBar()
                            .transition(.move(edge: .bottom))
                    }
                }
                .animation(.default, value: speakVM.isEditing)
                .navigationTitle("Speak")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Done") {
                            dismiss()
                        }
                        .font(.headline)
                    }
                }
        }
        .sheet(isPresented: $speakVM.showVoicesView) {
            VoicesView()
        }
        .environmentObject(speakVM)
    }
}
