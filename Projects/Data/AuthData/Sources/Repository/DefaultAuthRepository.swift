//
//  DefaultAuthRepository.swift
//  AuthData
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Moya

import AuthDomain
import BaseData

public final class DefaultAuthRepository: AuthRepository {
    private let authProvider: MoyaProvider<AuthTargetType>
    private let keyChainStorage: KeyChainStorage
    
    public init(
        authProvider: MoyaProvider<AuthTargetType>,
        keyChainStorage: KeyChainStorage
    ) {
        self.authProvider = authProvider
        self.keyChainStorage = keyChainStorage
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
}
