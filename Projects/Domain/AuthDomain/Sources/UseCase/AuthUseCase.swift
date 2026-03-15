//
//  AuthUseCase.swift
//  AuthDomain
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import BaseDomain

public protocol AuthUseCase {
    func executeSignIn(idToken: String, authorizationCode: String?, type: SignInType) async throws -> Bool
}

public final class DefaultAuthUseCase: AuthUseCase {
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    
    public init(
        authRepository: AuthRepository,
        userRepository: UserRepository
    ) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }
    
    public func executeSignIn(idToken: String, authorizationCode: String?, type: SignInType) async throws -> Bool {
        try await authRepository.fetchSignIn(idToken: idToken, authorizationCode: authorizationCode, type: type)
        
        let userInfo = try await userRepository.fetchUserInfo()
        
        return userInfo.isOnboarding
    }
}
