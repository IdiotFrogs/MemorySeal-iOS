//
//  UserUseCase.swift
//  BaseDomain
//
//  Created by 선민재 on 3/24/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public protocol UserUseCase {
    func fetchUserInfo() async throws -> UserInfoEntity
    func editProfile(nickname: String?, profileImage: Data?) async throws
    func deleteAccount() async throws
}

public final class DefaultUserUseCase: UserUseCase {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func fetchUserInfo() async throws -> UserInfoEntity {
        return try await userRepository.fetchUserInfo()
    }

    public func editProfile(nickname: String?, profileImage: Data?) async throws {
        try await userRepository.editProfile(nickname: nickname, profileImage: profileImage)
    }

    public func deleteAccount() async throws {
        try await userRepository.deleteAccount()
    }
}
