//
//  VoiceRow.swift
//  Speak
//
//  Created by Jack Finnis on 20/01/2023.
//

import SwiftUI
import AVFoundation

struct VoiceRow: View {
    @EnvironmentObject var speakVM: SpeakVM
    @EnvironmentObject var voicesVM: VoicesVM
    
    let voice: AVSpeechSynthesisVoice
    
    var selected: Bool { speakVM.voice == voice }
    
    var body: some View {
        Button {
            speakVM.voice = voice
            voicesVM.greet(voice: voice)
        } label: {
            HStack {
                if selected {
                    Image(systemName: "checkmark")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
                Text(voice.name)
                    .foregroundColor(.primary)
                Spacer()
                Text(voice.gender.initial)
                    .foregroundColor(.primary)
            }
        }
    }
}
