//
//  DefaultUserRepository.swift
//  AuthData
//
//  Created by 선민재 on 2/10/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Moya

import BaseDomain
import Foundation

public final class DefaultUserRepository: UserRepository {
    
    private let provider: DefaultProvider<UserTargetType>
    private let userDefaultStorage: UserDefaultStorage
    
    public init(
        provider: DefaultProvider<UserTargetType>,
        userDefaultStorage: UserDefaultStorage
    ) {
        self.provider = provider
        self.userDefaultStorage = userDefaultStorage
    }
    
    public func fetchUserInfo() async throws -> UserInfoEntity {
        let result = await provider.request(.userInfo)

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: UserInfoResponseDTO.self,
            errorType: UserInfoError.self
        )
        
        userDefaultStorage.set(value: responseDTO.id, forKey: .userId)

        return responseDTO.toDomain
    }

    public func uploadProfileImage(file: String) async throws -> String {
        guard let userId: Int = userDefaultStorage.get(forKey: .userId) as? Int else { throw UploadProfileImageError.defaultError }

        let result = await provider.request(.uploadProfileImage(userId: userId, file: file))

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: UploadProfileImageResponseDTO.self,
            errorType: UploadProfileImageError.self
        )

        return responseDTO.profileImageUrl
    }

    public func editProfile(nickname: String, profileImage: Data?) async throws {
        let result = await provider.request(.editProfile(nickname: nickname, profileImage: profileImage))

        try ResultHandler.handleResult(
            result: result,
            errorType: EditProfileError.self
        )
    }
}
