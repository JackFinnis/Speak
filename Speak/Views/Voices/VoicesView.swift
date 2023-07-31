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
                ForEach(groupedByQuality.keys.sorted { $0.rawValue > $1.rawValue }, id: \.self) { quality in
                    let groupedByCountry = Dictionary(grouping: groupedByQuality[quality]!, by: \.country)
                    
                    Text(quality.name)
                        .font(.title)
                        .listRowBackground(Color.clear)
                        .listRowInsets(.init())
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
            .searchable(text: $searchText.animation(), placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Select Voice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        showAddVoicesAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .alert("Add Voices", isPresented: $showAddVoicesAlert) {
                        Button("Cancel") {}
                        Button("Settings", role: .cancel) {
                            filesVM.openSettings()
                        }
                    } message: {
                        Text("You can download higher quality voices for free in the Settings app under Accessibility > Spoken Content > Voices. Any voices you download there will appear in this list.")
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
        .onDisappear {
            voicesVM.stop()
        }
    }
}

struct VoicesView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true)) {
                VoicesView()
            }
    }
}
