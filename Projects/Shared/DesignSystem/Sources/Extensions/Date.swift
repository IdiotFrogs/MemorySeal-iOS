//
//  Date.swift
//  DesignSystem
//
//  Created by 선민재 on 6/5/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation

extension Date {
    public var kstNow: Date {
        let kst = TimeZone(abbreviation: "KST") ?? TimeZone.current
        let timeInterval = TimeInterval(kst.secondsFromGMT(for: self))
        let kstNow = self.addingTimeInterval(timeInterval)
        return kstNow
    }
}
