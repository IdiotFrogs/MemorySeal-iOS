//
//  TimeCapsulePageEntity.swift
//  BaseDomain
//
//  Created by 선민재 on 9/8/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public struct TimeCapsulePageEntity {
    public let timeCapsules: [TimeCapsuleEntity]
    public let currentPage: Int
    public let isLast: Bool
    public let totalElements: Int

    public init(
        timeCapsules: [TimeCapsuleEntity],
        currentPage: Int,
        isLast: Bool,
        totalElements: Int
    ) {
        self.timeCapsules = timeCapsules
        self.currentPage = currentPage
        self.isLast = isLast
        self.totalElements = totalElements
    }
}
