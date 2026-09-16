//
//  HomeSectionModel.swift
//  HomePresentation
//
//  Created by 선민재 on 9/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import BaseDomain

public enum HomeSectionKind {
    case banner
    case hero
    case timeTicket
    case upcoming
}

public struct HomeSectionModel {
    public let kind: HomeSectionKind
    public let title: String?
    public let showsMore: Bool
    public let items: [TimeCapsuleEntity]

    public init(kind: HomeSectionKind, title: String?, showsMore: Bool, items: [TimeCapsuleEntity]) {
        self.kind = kind
        self.title = title
        self.showsMore = showsMore
        self.items = items
    }
}
