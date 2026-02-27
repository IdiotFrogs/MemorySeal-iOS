//
//  AuthorizationInterceptor.swift
//  BaseData
//
//  Created by 선민재 on 2/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation
import Alamofire
import BaseDomain


final class AuthorizationInterceptor: RequestInterceptor, @unchecked Sendable {
    static let shared = AuthorizationInterceptor()
    
    private let retryLimit: Int = 3
    private let tokenRefresher: TokenRefresher
    private let keyChainStorage: KeyChainStorage
    
    private init(
        tokenRefresher: TokenRefresher = DefaultTokenRefresher(),
        keyChainStorage: KeyChainStorage = DefaultKeyChainStorage()
    ) {
        self.tokenRefresher = tokenRefresher
        self.keyChainStorage = keyChainStorage
    }
    
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard retryLimit >= request.retryCount,
              let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            return completion(.doNotRetryWithError(error))
        }
        
        guard let absoluteString = request.request?.url?.absoluteString,
              absoluteString.contains("/auth/reissue") == false else {
            return completion(.doNotRetryWithError(error))
        }
        
        Task {
            do {
                try await refreshAccessToken()
                completion(.retry)
            } catch RefreshError.tokenExpired {
                completion(.doNotRetryWithError(error))
            } catch let error {
                completion(.doNotRetryWithError(error))
            }
        }
    }
    
    private func refreshAccessToken() async throws {
        guard let refreshToken: String = keyChainStorage.read(
            forKey: .refreshToken
        ) else { throw RefreshError.defaultError }
        
        let response = try await tokenRefresher.refreshAccessToken(with: refreshToken)
        
        keyChainStorage.update(response.accessToken, forKey: .accessToken)
        keyChainStorage.update(response.refreshToken, forKey: .refreshToken)
    }
}
