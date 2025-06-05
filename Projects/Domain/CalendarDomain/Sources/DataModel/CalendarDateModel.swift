//
//  CalendarDateModel.swift
//  CalendarDomain
//
//  Created by 선민재 on 6/5/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation

public struct CalendarDateModel {
    public let date: Date
    public let isInCurrentMonth: Bool
    public let isToday: Bool
    
    init(
        date: Date,
        isInCurrentMonth: Bool,
        isToday: Bool = false
    ) {
        self.date = date
        self.isInCurrentMonth = isInCurrentMonth
        self.isToday = isToday
    }
}
