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

    public init(content: String, season: String, timeCapsuleId: Int) {
        self.content = content
        self.season = season
        self.timeCapsuleId = timeCapsuleId
    }
}
