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
}

public final class DefaultUserUseCase: UserUseCase {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func fetchUserInfo() async throws -> UserInfoEntity {
        return try await userRepository.fetchUserInfo()
    }
}
