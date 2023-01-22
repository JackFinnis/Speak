//
//  VoiceRow.swift
//  Speak
//
//  Created by Jack Finnis on 20/01/2023.
//

import SwiftUI
import AVFoundation

struct VoiceRow: View {
    @ObservedObject var speakVM: SpeakVM
    @ObservedObject var voicesVM: VoicesVM
    let voice: AVSpeechSynthesisVoice
    
    var body: some View {
        Button {
            speakVM.voice = voice
        } label: {
            Row {
                Group {
                    if voicesVM.speaking == voice {
                        Button {
                            voicesVM.stop()
                        } label: {
                            Image(systemName: "stop.fill")
                        }
                    } else {
                        Button {
                            voicesVM.greet(voice: voice)
                        } label: {
                            Image(systemName: "play.fill")
                        }
                    }
                }
                .buttonStyle(.borderless)
                .frame(width: 25)
                
                Text(voice.name)
                    .foregroundColor(.primary)
            } trailing: {
                Text(voice.gender.initial)
                    .foregroundColor(.primary)
                
                if speakVM.voice == voice {
                    Image(systemName: "checkmark")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}
