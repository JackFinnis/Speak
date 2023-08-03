//
//  Double.swift
//  Speak
//
//  Created by Jack Finnis on 03/08/2023.
//

import Foundation

extension Double {
    func formattedInterval() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: self) ?? ""
    }
}
