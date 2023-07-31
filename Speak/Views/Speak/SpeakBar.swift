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
                VStack {
                    Text("Voice")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Button(speakVM.selectedVoice == nil ? "Select" : speakVM.selectedVoice!.name) {
                        speakVM.showVoicesView = true
                    }
                }
                .frame(width: geo.size.width / 3)
                
                HStack {
                    if !speakVM.isSpeaking {
                        Button {
                            speakVM.start()
                        } label: {
                            Image(systemName: "play.fill")
                        }
                        .frame(width: 40)
                    } else if speakVM.isPaused {
                        Button {
                            speakVM.resume()
                        } label: {
                            Image(systemName: "play.fill")
                        }
                        .frame(width: 40)
                    } else {
                        Button {
                            speakVM.pause()
                        } label: {
                            Image(systemName: "pause.fill")
                        }
                        .frame(width: 40)
                    }
                    Button {
                        speakVM.stop()
                    } label: {
                        Image(systemName: "stop.fill")
                    }
                    .frame(width: 40)
                    .disabled(!speakVM.isSpeaking)
                }
                .padding(10)
                .background(Color(.systemBackground))
                .continuousRadius(5)
                .frame(width: geo.size.width / 3)
                
                VStack {
                    Text("Speed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Stepper("", value: $speakVM.rate, in: 0...1, step: 0.05)
                        .frame(width: geo.size.width / 3)
                        .labelsHidden()
                }
                .frame(width: geo.size.width / 3)
            }
            .frame(height: geo.size.height)
        }
        .frame(height: 100)
        .font(.title2)
        .background(Color(.systemFill).ignoresSafeArea())
    }
}
