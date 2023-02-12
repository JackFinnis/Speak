//
//  VoicesView.swift
//  Speak
//
//  Created by Jack Finnis on 20/01/2023.
//

import SwiftUI
import AVFoundation

struct VoicesView: View {
    @EnvironmentObject var filesVM: FilesVM
    @ObservedObject var speakVM: SpeakVM
    @StateObject var voicesVM = VoicesVM()
    @State var text = ""
    @State var gender: AVSpeechSynthesisVoiceGender?
    @State var showAddAlert = false
    
    var filteredVoices: [AVSpeechSynthesisVoice] {
        filesVM.voices.filter {
            ($0.name.localizedCaseInsensitiveContains(text) || text.isEmpty) &&
            (gender == nil || $0.gender == gender)
        }
    }
    var groupedQuality: [AVSpeechSynthesisVoiceQuality: [AVSpeechSynthesisVoice]] {
        Dictionary(grouping: filteredVoices, by: \.quality)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupedQuality.keys.sorted { $0.rawValue > $1.rawValue }, id: \.self) { quality in
                    Section(quality.name) {}
                        .headerProminence(.increased)
                    var groupedCountry = Dictionary(grouping: groupedQuality[quality]!, by: \.country)
                    
                    if let voices = groupedCountry.removeValue(forKey: AVSpeechSynthesisVoice.country) {
                        VoicesCountry(speakVM: speakVM, voicesVM: voicesVM, country: AVSpeechSynthesisVoice.country, voices: voices)
                    }
                    
                    ForEach(groupedCountry.keys.sorted { $0 < $1 }, id: \.self) { country in
                        VoicesCountry(speakVM: speakVM, voicesVM: voicesVM, country: country, voices: groupedCountry[country]!)
                    }
                }
            }
            .animation(.default, value: filesVM.voices)
            .searchable(text: $text.animation(), placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Select Voice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    HStack {
                        Button {
                            showAddAlert = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .alert("Add Voices", isPresented: $showAddAlert) {
                            Button("Cancel") {}
                            Button("Settings", role: .cancel) {
                                filesVM.openSettings()
                            }
                        } message: {
                            Text("You can download higher quality voices for free in the Settings app under Accessibility > Spoken Content > Voices. Any voices you download there will appear in this list.")
                        }
                        
                        Menu(gender?.name ?? "Gender") {
                            Picker("Gender", selection: $gender.animation()) {
                                ForEach(AVSpeechSynthesisVoiceGender.allCases, id: \.self) { gender in
                                    Text(gender.name)
                                        .tag(gender as AVSpeechSynthesisVoiceGender?)
                                }
                                Text("All")
                                    .tag(nil as AVSpeechSynthesisVoiceGender?)
                            }
                        }
                    }
                    .animation(.none)
                }
                ToolbarItem(placement: .principal) {
                    DraggableBar("Select Voice")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        speakVM.showVoicesView = false
                    } label: {
                        DismissCross()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onDisappear {
            voicesVM.stop()
        }
    }
}

struct VoicesView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true)) {
                VoicesView(speakVM: SpeakVM(text: ""))
            }
    }
}

struct VoicesCountry: View {
    @ObservedObject var speakVM: SpeakVM
    @ObservedObject var voicesVM: VoicesVM
    
    let country: String
    let voices: [AVSpeechSynthesisVoice]
    
    var body: some View {
        Section(country) {
            ForEach(voices.sorted { $0.name < $1.name }, id: \.self) { voice in
                VoiceRow(speakVM: speakVM, voicesVM: voicesVM, voice: voice)
            }
        }
    }
}
