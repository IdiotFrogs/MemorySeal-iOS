//
//  UserInfoEntity.swift
//  UserDomain
//
//  Created by 선민재 on 2/10/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public struct UserInfoEntity {
    let id: Int
    let nickname: String
    let profileImageUrl: String
    let email: String
    let isOnboarding: Bool
    
    public init(
        id: Int,
        nickname: String,
        profileImageUrl: String,
        email: String,
        isOnboarding: Bool
    ) {
        self.id = id
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.email = email
        self.isOnboarding = isOnboarding
    }
}
