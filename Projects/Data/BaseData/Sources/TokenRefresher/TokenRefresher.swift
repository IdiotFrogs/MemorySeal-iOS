//
//  TokenRefresher.swift
//  BaseData
//
//  Created by 선민재 on 2/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation
import Moya
import BaseDomain

protocol TokenRefresher: Sendable {
    func refreshAccessToken(with refreshToken: String) async throws -> RefreshResponseDTO
}

final class DefaultTokenRefresher: TokenRefresher {
    func refreshAccessToken(with refreshToken: String) async throws -> RefreshResponseDTO {
        let authProvider = MoyaProvider<RefreshTargetType>()
        
        let result = await authProvider.request(.refreshAccessToken(refreshToken: refreshToken))
        
        let response = try ResultHandler.handleResult(
            result: result,
            responseType: RefreshResponseDTO.self,
            errorType: RefreshError.self
        )
        
        return response
    }
}
