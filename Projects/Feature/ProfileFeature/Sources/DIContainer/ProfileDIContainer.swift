//
//  ProfileDIContainer.swift
//  ProfileFeature
//
//  Created by 선민재 on 3/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import ProfilePresentation

public final class ProfileDIContainer {
    public init() {}

    public func makeProfileViewModel() -> ProfileViewModel {
        return ProfileViewModel()
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
}
