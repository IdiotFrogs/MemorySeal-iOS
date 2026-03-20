//
//  TimeCapsuleEntity.swift
//  BaseDomain
//
//  Created by 선민재 on 3/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public enum TimeCapsuleStatus: String {
    case opened = "OPENED"
    case buried = "BURIED"
    case beforeBuried = "BEFOREBURIED"
}

public enum TimeCapsuleRole: String {
    case host = "HOST"
    case contributor = "CONTRIBUTOR"
}

public struct TimeCapsuleEntity {
    public let timeCapsuleId: Int
    public let title: String
    public let openedAt: Date
    public let timeCapsuleStatus: TimeCapsuleStatus
    public let role: TimeCapsuleRole

    public init(
        timeCapsuleId: Int,
        title: String,
        openedAt: Date,
        timeCapsuleStatus: TimeCapsuleStatus,
        role: TimeCapsuleRole
    ) {
        self.timeCapsuleId = timeCapsuleId
        self.title = title
        self.openedAt = openedAt
        self.timeCapsuleStatus = timeCapsuleStatus
        self.role = role
    }
}
