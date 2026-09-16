//
//  SeasonalBannerEntity.swift
//  BaseDomain
//
//  Created by 선민재 on 9/8/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public struct SeasonalBannerEntity {
    public let content: String
    public let season: String
    public let timeCapsuleId: Int
    public let title: String?
    public let imageUrl: String?

    public init(
        content: String,
        season: String,
        timeCapsuleId: Int,
        title: String? = nil,
        imageUrl: String? = nil
    ) {
        self.content = content
        self.season = season
        self.timeCapsuleId = timeCapsuleId
        self.title = title
        self.imageUrl = imageUrl
    }
}
