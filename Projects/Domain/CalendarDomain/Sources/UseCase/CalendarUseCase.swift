//
//  CalendarUseCase.swift
//  CalendarDomain
//
//  Created by 선민재 on 6/5/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation

public protocol CalendarUseCase {
    func generateCalendarDates(for date: Date) -> [CalendarDateModel]
}

public final class DefaultCalendarUseCase: CalendarUseCase {
    public init() {}
    
    public func generateCalendarDates(for date: Date) -> [CalendarDateModel] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.timeZone = TimeZone(abbreviation: "UTC") ?? .current
        calendar.firstWeekday = 1
        
        let components = calendar.dateComponents([.year, .month], from: date)
        
        guard let year = components.year,
              let month = components.month else { return [] }
        
        let startOfMonthComponents = DateComponents(year: year, month: month, day: 1)
        
        guard let startOfMonth = calendar.date(from: startOfMonthComponents),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return [] }
        
        let numberOfDaysInMonth = range.count
        
        let weekdayOfFirstDay = calendar.component(.weekday, from: startOfMonth)
        let prefixEmptyCount = (weekdayOfFirstDay - calendar.firstWeekday + 7) % 7
        
        var dates: [CalendarDateModel] = []
        
        for i in stride(from: prefixEmptyCount, to: 0, by: -1) {
            if let date = calendar.date(
                byAdding: .day,
                value: -i,
                to: startOfMonth
            ) {
                dates.append(CalendarDateModel(date: date, isInCurrentMonth: false))
            }
        }
        
        for day in 0..<numberOfDaysInMonth {
            if let date = calendar.date(
                byAdding: .day,
                value: day,
                to: startOfMonth
            ) {
                dates.append(CalendarDateModel(date: date, isInCurrentMonth: true))
            }
        }
        
        while dates.count % 7 != 0 {
            if let lastDate = dates.last?.date,
               let nextDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: lastDate
               ) {
                dates.append(CalendarDateModel(date: nextDate, isInCurrentMonth: false))
            }
        }
        
        return dates
    }
}
