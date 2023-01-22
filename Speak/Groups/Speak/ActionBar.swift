//
//  ActionBar.swift
//  Speak
//
//  Created by Jack Finnis on 20/01/2023.
//

import SwiftUI

struct ActionBar: View {
    @ObservedObject var speakVM: SpeakVM
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Button {
                    speakVM.showVoicesView = true
                } label: {
                    Image(systemName: "person.wave.2" + (speakVM.voice == nil ? "" : ".fill"))
                }
                .frame(width: geo.size.width / 3)
                
                HStack {
                    if !speakVM.speaking {
                        Button {
                            speakVM.start()
                        } label: {
                            Image(systemName: "play.fill")
                        }
                        .frame(width: 40)
                    } else if speakVM.paused {
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
                    .disabled(!speakVM.speaking)
                }
                .frame(width: geo.size.width / 3)
                
                Stepper("Speaking Speed", value: $speakVM.rate, in: 0...1, step: 0.05)
                    .frame(width: geo.size.width / 3)
                    .labelsHidden()
            }
            .frame(height: geo.size.height)
        }
        .frame(height: 50)
        .font(.title2)
        .background(Color(.systemFill).ignoresSafeArea())
    }
}

struct ActionBar_Previews: PreviewProvider {
    static var previews: some View {
        ActionBar(speakVM: SpeakVM(text: ""))
    }
}
