//
//  SpeakBar.swift
//  Speak
//
//  Created by Jack Finnis on 20/01/2023.
//

import SwiftUI

struct SpeakBar: View {
    @EnvironmentObject var speakVM: SpeakVM
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                let width = (geo.size.width - 50) / 2
                
                VStack(spacing: 0) {
                    Text("Voice")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer(minLength: 0)
                    Button {
                        speakVM.showVoicesView = true
                        speakVM.pauseSpeaking()
                    } label: {
                        Text(speakVM.voice == nil ? "Select" : speakVM.voice!.firstName)
                            .font(.system(size: 20))
                    }
                    Spacer(minLength: 0)
                }
                .frame(width: width)
                
                Button {
                    speakVM.toggleSpeaking()
                } label: {
                    Image(systemName: "\(speakVM.state == .speaking ? "pause.fill" : "play.fill")")
                        .frame(width: 50, height: 50)
                }
                .font(.title)
                .background(Color(.systemBackground))
                .clipShape(Circle())
                
                VStack(spacing: 0) {
                    Text("Speed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer(minLength: 0)
                    Stepper("", value: $speakVM.rate, in: 0...1, step: 0.05)
                        .labelsHidden()
                    Spacer(minLength: 0)
                }
                .frame(width: width)
            }
            .frame(height: geo.size.height)
        }
        .frame(height: 60)
        .padding(.vertical, 5)
        .background(Color(.systemFill).ignoresSafeArea())
    }
}
