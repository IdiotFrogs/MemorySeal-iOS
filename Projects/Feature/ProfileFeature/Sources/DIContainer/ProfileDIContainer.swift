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

public final class ProfileDIContainer {
    public init() {}

    private func makeUserProvider() -> DefaultProvider<UserTargetType> {
        return DefaultProvider<UserTargetType>()
    }

    private func makeUserDefaultStorage() -> UserDefaultStorage {
        return DefaultUserDefaultStorage()
    }

    private func makeUserRepository() -> UserRepository {
        return DefaultUserRepository(
            provider: makeUserProvider(),
            userDefaultStorage: makeUserDefaultStorage()
        )
    }

    private func makeUserUseCase() -> UserUseCase {
        return DefaultUserUseCase(userRepository: makeUserRepository())
    }

    public func makeProfileViewModel() -> ProfileViewModel {
        return ProfileViewModel(userUseCase: makeUserUseCase())
    }

    public func makeProfileViewController(
        with viewModel: ProfileViewModel
    ) -> ProfileViewController {
        return ProfileViewController(with: viewModel)
    }

    public func makeEditProfileViewModel() -> EditProfileViewModel {
        return EditProfileViewModel()
    }

    public func makeEditProfileViewController(
        with viewModel: EditProfileViewModel
    ) -> EditProfileViewController {
        return EditProfileViewController(with: viewModel)
    }

    public func makeSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel()
    }

    public func makeSettingsViewController(
        with viewModel: SettingsViewModel
    ) -> SettingsViewController {
        return SettingsViewController(with: viewModel)
    }
}
