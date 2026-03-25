//
//  UserRepository.swift
//  UserDomain
//
//  Created by 선민재 on 2/10/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public protocol UserRepository {
    func fetchUserInfo() async throws -> UserInfoEntity
    func uploadProfileImage(file: String) async throws -> String
    func editProfile(nickname: String, profileImage: Data?) async throws
}
