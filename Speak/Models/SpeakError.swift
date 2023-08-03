//
//  SpeakError.swift
//  Speak
//
//  Created by Jack Finnis on 31/07/2023.
//

import Foundation

enum SpeakError {
    case openFile
    case readFile
    case createFile
    case exportFile
    case writeFile
    
    var title: String {
        switch self {
        case .openFile:
            return "File Not Imported"
        case .readFile:
            return "File Not Imported"
        case .createFile:
            return "File Not Exported"
        case .exportFile:
            return "File Not Exported"
        case .writeFile:
            return "File Not Exported"
        }
    }
    
    var description: String {
        switch self {
        case .openFile:
            return "We don't have permission to open this file. Please ensure it is downloaded from iCloud and try again."
        case .readFile:
            return "Please ensure this file contains text and try again."
        case .createFile:
            return "Please try again later."
        case .exportFile:
            return "Please try again later."
        case .writeFile:
            return "Please try again later."
        }
    }
}
