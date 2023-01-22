//
//  Defaults.swift
//  Change
//
//  Created by Jack Finnis on 07/11/2022.
//

import Foundation

@propertyWrapper
struct Defaults<Value> {
    let defaults = UserDefaults.standard
    
    let key: String
    let defaultValue: Value
    
    init(wrappedValue defaultValue: Value, _ key: String) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: Value {
        get {
            defaults.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            defaults.set(newValue, forKey: key)
        }
    }
}
