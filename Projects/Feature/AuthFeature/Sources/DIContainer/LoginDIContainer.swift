//
//  LoginDIContainer.swift
//  LoginFeature
//
//  Created by 선민재 on 5/1/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation
import Moya

import AuthPresentation
import AuthData
import AuthDomain
import BaseData
import BaseDomain

public final class LoginDIContainer {
    private func makeAuthProvdier() -> MoyaProvider<AuthTargetType> {
        return MoyaProvider<AuthTargetType>()
    }
    
    private func makeUserProvdier() -> DefaultProvider<UserTargetType> {
        return DefaultProvider<UserTargetType>()
    }
    
    private func makeKeyChainStorage() -> KeyChainStorage {
        return DefaultKeyChainStorage()
    }
    
    private func makeUserDefaultStorage() -> UserDefaultStorage {
        return DefaultUserDefaultStorage()
    }
    
    private func makeAuthRepository() -> AuthRepository {
        return DefaultAuthRepository(
            authProvider: makeAuthProvdier(),
            keyChainStorage: makeKeyChainStorage()
        )
    }
    
    private func makeUserRepository() -> UserRepository {
        return DefaultUserRepository(
            provider: makeUserProvdier(),
            userDefaultStorage: makeUserDefaultStorage()
        )
    }
    
    private func makeAuthUseCase() -> AuthUseCase {
        return DefaultAuthUseCase(
            authRepository: makeAuthRepository(),
            userRepository: makeUserRepository()
        )
    }
    
    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(
            authUseCase: makeAuthUseCase()
        )
    }
    
    func makeLoginViewController(
        with viewModel: LoginViewModel
    ) -> LoginViewController {
        return LoginViewController(with: viewModel)
    }
}
