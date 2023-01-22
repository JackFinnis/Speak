//
//  URL.swift
//  Speak
//
//  Created by Jack Finnis on 22/01/2023.
//

import Foundation

extension URL {
    var name: String { deletingPathExtension().lastPathComponent }
}
