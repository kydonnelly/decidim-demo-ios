//
//  Date+Helpers.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/30/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

extension Calendar.Component {
    
    public var asUnit: NSCalendar.Unit? {
        switch self {
        case .year: return .year
        case .month: return .month
        case .day: return .day
        case .hour: return .hour
        case .minute: return .minute
        case .second: return .second
        default: return nil
        }
    }
    
}

extension DateComponents {
    
    public func value(component: Calendar.Component) -> Int? {
        switch component {
        case .year: return self.year ?? 0 > 0 ? self.year : nil
        case .month: return self.month ?? 0 > 0 ? self.month : nil
        case .day: return self.day ?? 0 > 0 ? self.day : nil
        case .hour: return self.hour ?? 0 > 0 ? self.hour : nil
        case .minute: return self.minute ?? 0 > 0 ? self.minute : nil
        case .second: return self.second ?? 0 > 0 ? self.second : nil
        default: return nil
        }
    }
    
}

extension Date {
    
    public func asShortStringAgo(from futureDate: Date = Date()) -> String {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.unitsStyle = .full
        let calendar = NSCalendar.current
        let calendarComponents: [Calendar.Component] = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        let components = calendar.dateComponents(Set(calendarComponents), from: self, to: futureDate)
        
        guard let matchingIndex = calendarComponents.firstIndex(where: { components.value(component: $0) != nil }),
              let matchingUnit = calendarComponents[matchingIndex].asUnit else {
            return "Just now"
        }
        
        dateFormatter.allowedUnits = matchingUnit
        guard let string = dateFormatter.string(from: components) else {
            return "Just now"
        }
        
        return "\(string) ago"
    }
    
    public func asShortStringLeft(until futureDate: Date = Date()) -> String {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.unitsStyle = .full
        let calendar = NSCalendar.current
        let calendarComponents: [Calendar.Component] = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        let components = calendar.dateComponents(Set(calendarComponents), from: futureDate, to: self)
        
        guard let matchingIndex = calendarComponents.firstIndex(where: { components.value(component: $0) != nil }),
              let matchingUnit = calendarComponents[matchingIndex].asUnit else {
            return "No time left"
        }
        
        dateFormatter.allowedUnits = matchingUnit
        guard let string = dateFormatter.string(from: components) else {
            return "No time left"
        }
        
        return "\(string) left"
    }
    
    public var isFuture: Bool {
        return self.compare(Date()) == .orderedDescending
    }
    
}

extension Date {
    
    public init?(timestamp: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = formatter.date(from: timestamp) else {
            return nil
        }
        
        self = date
    }
    
}
