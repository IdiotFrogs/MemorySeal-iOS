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
        
        do {
            return try ResultHandler.handleResult(
                result: result,
                responseType: RefreshResponseDTO.self,
                errorType: RefreshError.self
            )
        } catch let error as RefreshError {
            throw error
        } catch {
            guard case .success(let response) = result,
                  isRejected(statusCode: response.statusCode) else { throw error }
            throw RefreshError.defaultError
        }
    }

    private func isRejected(statusCode: Int) -> Bool {
        return (400..<500).contains(statusCode) || statusCode == 500
    }
}
