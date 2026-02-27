//
//  DefaultUserRepository.swift
//  AuthData
//
//  Created by 선민재 on 2/10/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Moya

import BaseDomain

public final class DefaultUserRepository: UserRepository {
    
    private let provider: DefaultProvider<UserTargetType>
    
    public init(
        provider: DefaultProvider<UserTargetType>
    ) {
        self.provider = provider
    }
    
    public func fetchUserInfo() async throws -> UserInfoEntity {
        let result = await provider.request(.userInfo)
        
        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: UserInfoResponseDTO.self,
            errorType: UserInfoError.self
        )
        
        return responseDTO.toDomain
    }
}
