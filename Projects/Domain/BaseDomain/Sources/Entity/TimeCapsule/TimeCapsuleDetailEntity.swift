//
//  TimeCapsuleDetailEntity.swift
//  BaseDomain
//
//  Created by 선민재 on 5/19/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public struct TimeCapsuleDetailEntity {
    public let title: String
    public let description: String
    public let createdAt: Date
    public let buriedAt: Date?
    public let openedAt: Date?
    public let mainImageUrl: String?
    public let timeCapsuleStatus: TimeCapsuleStatus
    public let userRole: TimeCapsuleRole
    public let myContentCount: Int
    public let myImageCount: Int

    public init(
        title: String,
        description: String,
        createdAt: Date,
        buriedAt: Date?,
        openedAt: Date?,
        mainImageUrl: String?,
        timeCapsuleStatus: TimeCapsuleStatus,
        userRole: TimeCapsuleRole,
        myContentCount: Int,
        myImageCount: Int
    ) {
        self.title = title
        self.description = description
        self.createdAt = createdAt
        self.buriedAt = buriedAt
        self.openedAt = openedAt
        self.mainImageUrl = mainImageUrl
        self.timeCapsuleStatus = timeCapsuleStatus
        self.userRole = userRole
        self.myContentCount = myContentCount
        self.myImageCount = myImageCount
    }
}
