//
//  TimeCapsuleDetailResponseDTO.swift
//  BaseData
//
//  Created by 선민재 on 5/19/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import BaseDomain

struct TimeCapsuleDetailResponseDTO: Decodable {
    let title: String
    let description: String?
    let createdAt: String
    let buriedAt: String?
    let openedAt: String?
    let mainImageUrl: String?
    let timeCapsuleStatus: String
    let userRole: String
    let myContentCount: Int
    let myImageCount: Int

    var toDomain: TimeCapsuleDetailEntity {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let parseDate: (String?) -> Date? = { iso in
            guard let iso else { return nil }
            return formatter.date(from: iso)
        }

        return .init(
            title: title,
            description: description ?? "",
            createdAt: parseDate(createdAt) ?? Date(),
            buriedAt: parseDate(buriedAt),
            openedAt: parseDate(openedAt),
            mainImageUrl: mainImageUrl,
            timeCapsuleStatus: TimeCapsuleStatus(rawValue: timeCapsuleStatus) ?? .beforeBuried,
            userRole: TimeCapsuleRole(rawValue: userRole) ?? .contributor,
            myContentCount: myContentCount,
            myImageCount: myImageCount
        )
    }
}
