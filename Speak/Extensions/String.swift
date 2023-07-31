//
//  String.swift
//  Speak
//
//  Created by Jack Finnis on 22/01/2023.
//

import Foundation

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
