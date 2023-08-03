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
    @EnvironmentObject var speakVM: SpeakVM
    @StateObject var voicesVM = VoicesVM()
    @State var showAddVoicesAlert = false
    @State var searchText = ""
    
    var filteredVoices: [AVSpeechSynthesisVoice] {
        filesVM.voices.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty
        }
    }
    
    var groupedByQuality: [AVSpeechSynthesisVoiceQuality: [AVSpeechSynthesisVoice]] {
        Dictionary(grouping: filteredVoices, by: \.quality)
    }
    
    var body: some View {
        NavigationView {
            List {
                ListBuffer(isPresented: filteredVoices.isEmpty)
                ForEach(groupedByQuality.keys.sorted { $0.rawValue > $1.rawValue }, id: \.self) { quality in
                    let groupedByCountry = Dictionary(grouping: groupedByQuality[quality]!, by: \.locale.countryName)
                    
                    Section(quality.name) {}
                        .headerProminence(.increased)
                    ForEach(groupedByCountry.keys.sorted { $0 < $1 }, id: \.self) { country in
                        let voices = groupedByCountry[country]!
                        
                        Section(country) {
                            ForEach(voices.sorted { $0.name < $1.name }, id: \.self) { voice in
                                VoiceRow(voice: voice)
                            }
                        }
                    }
                }
            }
            .animation(.default, value: filesVM.voices)
            .navigationTitle("Select Voice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        showAddVoicesAlert = true
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                    .alert("Download More Voices", isPresented: $showAddVoicesAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Open Settings") {
                            filesVM.openSettings()
                        }
                    } message: {
                        Text("You can download higher quality voices for free in the Settings app under Accessibility > Spoken Content > Voices.")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        speakVM.showVoicesView = false
                    }
                    .font(.headline)
                }
            }
        }
        .overlay {
            if filesVM.voices.isEmpty {
                VStack {
                    BigLabel(systemName: "person.wave.2.fill", title: "No Voices Available", message: "Please download voices in the Settings app under Accessibility > Spoken Content > Voices.")
                    Button("Open Settings") {
                        filesVM.openSettings()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if filteredVoices.isEmpty {
                Text("No Results Found")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .onDisappear {
            voicesVM.stopSpeaking()
        }
        .environmentObject(voicesVM)
    }
}
