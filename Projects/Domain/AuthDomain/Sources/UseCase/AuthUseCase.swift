//
//  AuthUseCase.swift
//  AuthDomain
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

public protocol AuthUseCase {
    func executeSignIn(_ idToken: String) async throws
}

public final class DefaultAuthUseCase: AuthUseCase {
    private let authRepository: AuthRepository
    
    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    public func executeSignIn(_ idToken: String) async throws {
        try await authRepository.fetchSignIn(idToken)
    }
}
