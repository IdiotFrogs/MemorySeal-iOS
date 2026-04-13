//
//  SignInDIContainer.swift
//  LoginFeature
//
//  Created by 선민재 on 5/1/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation
import Moya

import SignInPresentation
import SignInData
import SignInDomain
import BaseData
import BaseDomain

public final class SignInDIContainer {
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
            keyChainStorage: makeKeyChainStorage(),
            userDefaultStorage: makeUserDefaultStorage()
        )
    }
    
    private func makeUserRepository() -> UserRepository {
        return DefaultUserRepository(
            provider: makeUserProvdier(),
            userDefaultStorage: makeUserDefaultStorage(),
            keyChainStorage: makeKeyChainStorage()
        )
    }
    
    private func makeAuthUseCase() -> AuthUseCase {
        return DefaultAuthUseCase(
            authRepository: makeAuthRepository(),
            userRepository: makeUserRepository()
        )
    }
    
    func makeSignInViewModel() -> SignInViewModel {
        return SignInViewModel(
            authUseCase: makeAuthUseCase()
        )
    }
    
    func makeSignInViewController(
        with viewModel: SignInViewModel
    ) -> SignInViewController {
        return SignInViewController(with: viewModel)
    }
}
