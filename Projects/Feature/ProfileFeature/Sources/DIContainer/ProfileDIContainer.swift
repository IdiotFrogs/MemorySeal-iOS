//
//  ProfileDIContainer.swift
//  ProfileFeature
//
//  Created by 선민재 on 3/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import ProfilePresentation
import BaseData
import BaseDomain
import SignInData
import SignInDomain

public final class ProfileDIContainer {
    public init() {}

    private func makeUserProvider() -> DefaultProvider<UserTargetType> {
        return DefaultProvider<UserTargetType>()
    }

    private func makeUserDefaultStorage() -> UserDefaultStorage {
        return DefaultUserDefaultStorage()
    }

    private func makeKeyChainStorage() -> KeyChainStorage {
        return DefaultKeyChainStorage()
    }

    private func makeUserRepository() -> UserRepository {
        return DefaultUserRepository(
            provider: makeUserProvider(),
            userDefaultStorage: makeUserDefaultStorage(),
            keyChainStorage: makeKeyChainStorage()
        )
    }

    private func makeUserUseCase() -> UserUseCase {
        return DefaultUserUseCase(userRepository: makeUserRepository())
    }

    private func makeAuthProvider() -> DefaultProvider<AuthTargetType> {
        return DefaultProvider<AuthTargetType>()
    }

    private func makeAuthRepository() -> AuthRepository {
        return DefaultAuthRepository(
            authProvider: makeAuthProvider(),
            keyChainStorage: makeKeyChainStorage(),
            userDefaultStorage: makeUserDefaultStorage()
        )
    }

    private func makeAuthUseCase() -> AuthUseCase {
        return DefaultAuthUseCase(
            authRepository: makeAuthRepository(),
            userRepository: makeUserRepository()
        )
    }

    private func makeProfileViewModel(action: ProfileViewModel.Action) -> ProfileViewModel {
        return ProfileViewModel(userUseCase: makeUserUseCase(), action: action)
    }

    public func makeProfileViewController(action: ProfileViewModel.Action) -> ProfileViewController {
        return ProfileViewController(with: makeProfileViewModel(action: action))
    }

    private func makeEditProfileViewModel(
        action: EditProfileViewModel.Action,
        nickname: String,
        profileImageUrl: String
    ) -> EditProfileViewModel {
        return EditProfileViewModel(
            userUseCase: makeUserUseCase(),
            action: action,
            nickname: nickname,
            profileImageUrl: profileImageUrl
        )
    }

    public func makeEditProfileViewController(
        action: EditProfileViewModel.Action,
        nickname: String,
        profileImageUrl: String
    ) -> EditProfileViewController {
        return EditProfileViewController(with: makeEditProfileViewModel(action: action, nickname: nickname, profileImageUrl: profileImageUrl))
    }

    private func makeSettingsViewModel(action: SettingsViewModel.Action) -> SettingsViewModel {
        return SettingsViewModel(
            authUseCase: makeAuthUseCase(),
            userUseCase: makeUserUseCase(),
            action: action
        )
    }

    public func makeSettingsViewController(action: SettingsViewModel.Action) -> SettingsViewController {
        return SettingsViewController(with: makeSettingsViewModel(action: action))
    }
}
