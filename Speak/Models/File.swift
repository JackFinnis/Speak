//
//  File.swift
//  Speak
//
//  Created by Jack Finnis on 30/07/2023.
//

import Foundation
import CoreData

@objc(File)
class File: NSManagedObject, Identifiable {
    @NSManaged var name: String
    @NSManaged var text: String
    @NSManaged var recentDate: Date
    @NSManaged var currentIndex: Int16
}
