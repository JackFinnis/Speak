//
//  View.swift
//  Speak
//
//  Created by Jack Finnis on 22/01/2023.
//

import SwiftUI

extension View {
    func horizontallyCentred() -> some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            self
            Spacer(minLength: 0)
        }
    }
    
    func bigButton() -> some View {
        self
            .font(.headline)
            .padding()
            .horizontallyCentred()
            .foregroundColor(.white)
            .background(Color.accentColor)
            .continuousRadius(15)
    }
    
    func continuousRadius(_ cornerRadius: CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
    
    func shadow() -> some View {
        self.compositingGroup()
            .shadow(color: Color.black.opacity(0.2), radius: 5, y: 5)
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ applyModifier: Bool = true, @ViewBuilder content: (Self) -> Content) -> some View {
        if applyModifier {
            content(self)
        } else {
            self
        }
    }
}
