//
//  Date.swift
//  Speak
//
//  Created by Jack Finnis on 03/08/2023.
//

import Foundation

extension Date {
    func formattedApple() -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        let oneWeekAgo = calendar.startOfDay(for: Date.now.addingTimeInterval(-7*24*3600))
        
        if calendar.isDateInToday(self) {
            return formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInYesterday(self) {
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .full
        } else if self > oneWeekAgo {
            formatter.dateFormat = "EEEE"
        } else if calendar.isDate(self, equalTo: .now, toGranularity: .year) {
            formatter.dateFormat = "d MMM"
        } else {
            formatter.dateFormat = "d MMM y"
        }
        return formatter.string(from: self)
    }
}
