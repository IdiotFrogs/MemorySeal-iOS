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
import AuthData
import AuthDomain

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

    public func makeProfileViewModel() -> ProfileViewModel {
        return ProfileViewModel(userUseCase: makeUserUseCase())
    }

    public func makeProfileViewController(
        with viewModel: ProfileViewModel
    ) -> ProfileViewController {
        return ProfileViewController(with: viewModel)
    }

    public func makeEditProfileViewModel(
        nickname: String,
        profileImageUrl: String
    ) -> EditProfileViewModel {
        return EditProfileViewModel(
            userUseCase: makeUserUseCase(),
            nickname: nickname,
            profileImageUrl: profileImageUrl
        )
    }

    public func makeEditProfileViewController(
        with viewModel: EditProfileViewModel
    ) -> EditProfileViewController {
        return EditProfileViewController(with: viewModel)
    }

    public func makeSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel(
            authUseCase: makeAuthUseCase(),
            userUseCase: makeUserUseCase()
        )
    }

    public func makeSettingsViewController(
        with viewModel: SettingsViewModel
    ) -> SettingsViewController {
        return SettingsViewController(with: viewModel)
    }
}
