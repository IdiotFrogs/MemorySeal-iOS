//
//  SplashDIContainer.swift
//  SplashFeature
//
//  Created by 선민재 on 3/19/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation
import Moya

import SplashPresentation
import SignInData
import SignInDomain
import BaseData
import BaseDomain

public final class SplashDIContainer {
    private func makeAuthProvider() -> MoyaProvider<AuthTargetType> {
        return MoyaProvider<AuthTargetType>()
    }

    private func makeUserProvider() -> DefaultProvider<UserTargetType> {
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
            authProvider: makeAuthProvider(),
            keyChainStorage: makeKeyChainStorage(),
            userDefaultStorage: makeUserDefaultStorage()
        )
    }

    private func makeUserRepository() -> UserRepository {
        return DefaultUserRepository(
            provider: makeUserProvider(),
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

    private func makeSplashViewModel(action: SplashViewModel.Action) -> SplashViewModel {
        return SplashViewModel(authUseCase: makeAuthUseCase(), action: action)
    }

    func makeSplashViewController(action: SplashViewModel.Action) -> SplashViewController {
        return SplashViewController(with: makeSplashViewModel(action: action))
    }
}
