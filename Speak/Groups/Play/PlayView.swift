//
//  PlayView.swift
//  Speak
//
//  Created by Jack Finnis on 22/01/2023.
//

import SwiftUI

struct PlayView: View {
    let url: URL
    
    var body: some View {
        Text("PlayView")
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView(url: URL(string: "www.bbc.com")!)
    }
}
