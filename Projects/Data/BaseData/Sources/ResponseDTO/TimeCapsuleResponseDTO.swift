//
//  TimeCapsuleResponseDTO.swift
//  BaseData
//
//  Created by 선민재 on 3/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import BaseDomain

struct TimeCapsuleResponseDTO: Decodable {
    let timeCapsuleId: Int
    let title: String
    let openedAt: String
    let timeCapsuleStatus: String
    let role: String

    var toDomain: TimeCapsuleEntity {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = dateFormatter.date(from: openedAt) ?? Date()

        return .init(
            timeCapsuleId: timeCapsuleId,
            title: title,
            openedAt: date,
            timeCapsuleStatus: TimeCapsuleStatus(rawValue: timeCapsuleStatus) ?? .beforeBuried,
            role: TimeCapsuleRole(rawValue: role) ?? .host
        )
    }
}
