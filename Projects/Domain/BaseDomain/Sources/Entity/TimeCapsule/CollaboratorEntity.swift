//
//  CollaboratorEntity.swift
//  BaseDomain
//
//  Created by 선민재 on 5/19/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public struct CollaboratorEntity {
    public let userId: Int
    public let nickname: String
    public let profileImageUrl: String?
    public let contributorRole: TimeCapsuleRole
    public let userActiveStatus: Bool
    public let isMe: Bool

    public init(
        userId: Int,
        nickname: String,
        profileImageUrl: String?,
        contributorRole: TimeCapsuleRole,
        userActiveStatus: Bool,
        isMe: Bool
    ) {
        self.userId = userId
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.contributorRole = contributorRole
        self.userActiveStatus = userActiveStatus
        self.isMe = isMe
    }
}
