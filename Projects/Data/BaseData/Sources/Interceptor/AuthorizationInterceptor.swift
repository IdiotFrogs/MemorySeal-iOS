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

    private static let authorizationHeader: String = "Authorization"
    private static let reissuePath: String = "/auth/reissue"

    private let retryLimit: Int = 3
    private let tokenRefresher: TokenRefresher
    private let keyChainStorage: KeyChainStorage
    private let refreshCoordinator: TokenRefreshCoordinator = TokenRefreshCoordinator()

    private init(
        tokenRefresher: TokenRefresher = DefaultTokenRefresher(),
        keyChainStorage: KeyChainStorage = DefaultKeyChainStorage()
    ) {
        self.tokenRefresher = tokenRefresher
        self.keyChainStorage = keyChainStorage
    }

    // MARK: - Adapt

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        guard urlRequest.value(forHTTPHeaderField: Self.authorizationHeader) != nil,
              let accessToken: String = keyChainStorage.read(forKey: .accessToken)
        else {
            return completion(.success(urlRequest))
        }

        var urlRequest = urlRequest
        urlRequest.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: Self.authorizationHeader
        )

        completion(.success(urlRequest))
    }

    // MARK: - Retry

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
              absoluteString.contains(Self.reissuePath) == false else {
            return completion(.doNotRetryWithError(error))
        }

        let attemptedToken = request.request?.value(forHTTPHeaderField: Self.authorizationHeader)

        Task {
            do {
                try await self.refreshCoordinator.refresh {
                    guard self.currentAuthorizationHeader() == attemptedToken else { return }
                    try await self.refreshAccessToken()
                }
                completion(.retry)
            } catch RefreshError.tokenExpired {
                completion(.doNotRetryWithError(error))
            } catch let error {
                completion(.doNotRetryWithError(error))
            }
        }
    }

    private func currentAuthorizationHeader() -> String? {
        guard let accessToken: String = keyChainStorage.read(forKey: .accessToken) else { return nil }
        return "Bearer \(accessToken)"
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

// MARK: - TokenRefreshCoordinator

private actor TokenRefreshCoordinator {
    private var ongoingTask: Task<Void, Error>?

    func refresh(_ operation: @escaping () async throws -> Void) async throws {
        if let ongoingTask {
            return try await ongoingTask.value
        }

        let task = Task { try await operation() }
        ongoingTask = task
        defer { ongoingTask = nil }

        try await task.value
    }
}
