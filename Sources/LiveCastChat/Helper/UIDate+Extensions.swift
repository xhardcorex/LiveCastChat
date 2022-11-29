//
//  UIDate+Extensions.swift
//  LiveCast
//
//  Created by vladimir.kuzomenskyi on 18.03.2022.
//

import Foundation

extension Date {
    
    static private var formatter = DateFormatter()
    
    var isJustNow: Bool {
        guard abs(self.timeIntervalSinceNow) < 90 else { return false }
        return true
    }
    
    var isToday: Bool {
        return Calendar.autoupdatingCurrent.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        return Calendar.autoupdatingCurrent.isDateInYesterday(self)
    }
    
    var isThisWeek: Bool {
        guard abs(self.timeIntervalSinceNow) < 7 * 24 * 60 * 60 else { return false }
        return true
    }
    
    var prettyPrinted: String {
        
        if isJustNow {
            return "Just now"
        }
        
        if isToday {
            Self.formatter.dateFormat = "HH:mm"
            return "Today, " + Self.formatter.string(from: self)
        }
        
        if isYesterday {
            Self.formatter.dateFormat = "HH:mm"
            return "Yesterday, " + Self.formatter.string(from: self)
        }
        
        if isThisWeek {
            Self.formatter.dateFormat = "EEEE, HH:mm"
            return Self.formatter.string(from: self)
        }
        
        Self.formatter.dateFormat = "MMM d, HH:mm"
        return Self.formatter.string(from: self)
    }
    
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
