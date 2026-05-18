//
//  CollaboratorResponseDTO.swift
//  BaseData
//
//  Created by 선민재 on 5/19/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import BaseDomain

struct CollaboratorResponseDTO: Decodable {
    let contributorRole: String
    let nickname: String
    let userId: Int
    let profileImageUrl: String?
    let userActiveStatus: Bool
    let isMe: Bool

    var toDomain: CollaboratorEntity {
        return .init(
            userId: userId,
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            contributorRole: TimeCapsuleRole(rawValue: contributorRole) ?? .contributor,
            userActiveStatus: userActiveStatus,
            isMe: isMe
        )
    }
}
