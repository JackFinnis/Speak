//
//  ListBuffer.swift
//  Speak
//
//  Created by Jack Finnis on 03/08/2023.
//

import SwiftUI

struct ListBuffer: View {
    let isPresented: Bool
    
    var body: some View {
        if isPresented {
            Section {
                Spacer().listRowBackground(Color.clear)
            }
        }
    }
}
