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
    private let authProvider: MoyaProvider<AuthTargetType> = .init()
    
    public init() {}
    
    public func fetchSignIn(_ idToken: String) async throws {
        let requestDTO: SignInRequestDTO = .init(idToken: idToken)
        
        let result = await authProvider.request(.signIn(requestDTO))
        
        let _ = try ResultHandler.handleResult(
            result: result,
            responseType: SignInResponseDTO.self,
            errorType: AuthError.self
        )
    }
}
