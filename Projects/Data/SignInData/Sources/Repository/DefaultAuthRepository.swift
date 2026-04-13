//
//  DefaultAuthRepository.swift
//  AuthData
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Moya

import SignInDomain
import BaseData

public final class DefaultAuthRepository: AuthRepository {
    private let authProvider: MoyaProvider<AuthTargetType>
    private let keyChainStorage: KeyChainStorage
    private let userDefaultStorage: UserDefaultStorage

    public init(
        authProvider: MoyaProvider<AuthTargetType>,
        keyChainStorage: KeyChainStorage,
        userDefaultStorage: UserDefaultStorage
    ) {
        self.authProvider = authProvider
        self.keyChainStorage = keyChainStorage
        self.userDefaultStorage = userDefaultStorage
    }

    public func hasAccessToken() -> Bool {
        return keyChainStorage.read(forKey: .accessToken) != nil
    }

    public func fetchSignIn(idToken: String, authorizationCode: String?, type: SignInType) async throws {

        let requestDTO: SignInRequestDTO = .init(idToken: idToken, authorizationCode: authorizationCode)

        let result = await authProvider.request(.signIn(requestDTO, type: type))

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: SignInResponseDTO.self,
            errorType: AuthError.self
        )

        keyChainStorage.add(
            value: responseDTO.accessToken,
            forKey: .accessToken
        )

        keyChainStorage.add(
            value: responseDTO.refreshToken,
            forKey: .refreshToken
        )
    }

    public func logout() async throws {
        _ = await authProvider.request(.logout)
        _ = keyChainStorage.delete(key: .accessToken)
        _ = keyChainStorage.delete(key: .refreshToken)
        userDefaultStorage.remove(forKey: .userId)
    }
}
