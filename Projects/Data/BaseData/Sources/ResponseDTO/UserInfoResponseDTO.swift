//
//  UserInfoResponseDTO.swift
//  AuthData
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import BaseDomain

struct UserInfoResponseDTO: Decodable {
    let id: Int
    let nickname: String
    let profileImageUrl: String
    let email: String
    let isOnboarding: Bool
    
    var toDomain: UserInfoEntity {
        return .init(
            id: id,
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            email: email,
            isOnboarding: isOnboarding
        )
    }
}
