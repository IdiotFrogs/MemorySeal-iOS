//
//  ProfileCoordinator.swift
//  ProfileFeature
//
//  Created by 선민재 on 3/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import ProfilePresentation

public final class ProfileCoordinator {
    public struct Dependency {
        public let moveToBack: () -> Void
        public let didLogout: () -> Void
        public let didEditProfile: () -> Void

        public init(
            moveToBack: @escaping () -> Void,
            didLogout: @escaping () -> Void,
            didEditProfile: @escaping () -> Void
        ) {
            self.moveToBack = moveToBack
            self.didLogout = didLogout
            self.didEditProfile = didEditProfile
        }
    }

    private let navigationController: UINavigationController
    private let profileDIContainer: ProfileDIContainer = .init()
    private let dependency: Dependency

    private var profileViewModel: ProfileViewModel?

    public init(with navigationController: UINavigationController, dependency: Dependency) {
        self.navigationController = navigationController
        self.dependency = dependency
    }

    public func start() {
        let profileAction = ProfileViewModel.Action(
            moveToBack: dependency.moveToBack,
            moveToEditProfile: moveToEditProfile,
            moveToSettings: moveToSettings
        )
        let profileViewModel = profileDIContainer.makeProfileViewModel(action: profileAction)
        self.profileViewModel = profileViewModel
        let profileViewController = profileDIContainer.makeProfileViewController(with: profileViewModel)
        self.navigationController.pushViewController(
            profileViewController,
            animated: true
        )
    }

    private func moveToEditProfile(nickname: String, profileImageUrl: String) {
        let editAction = EditProfileViewModel.Action(
            moveToBack: popViewController,
            didEditProfile: { [weak self] in
                self?.profileViewModel?.refresh()
                self?.dependency.didEditProfile()
            }
        )
        let editProfileViewController = profileDIContainer.makeEditProfileViewController(
            action: editAction,
            nickname: nickname,
            profileImageUrl: profileImageUrl
        )
        self.navigationController.pushViewController(
            editProfileViewController,
            animated: true
        )
    }

    private func moveToSettings() {
        let settingsAction = SettingsViewModel.Action(
            moveToBack: popViewController,
            moveToTermsOfService: moveToTermsOfService,
            moveToLogout: dependency.didLogout,
            moveToWithdrawal: dependency.didLogout
        )
        let settingsViewController = profileDIContainer.makeSettingsViewController(action: settingsAction)
        self.navigationController.pushViewController(
            settingsViewController,
            animated: true
        )
    }

    private func popViewController() {
        self.navigationController.popViewController(animated: true)
    }

    private func moveToTermsOfService() {
        // TODO: Navigate to Terms of Service
    }
}
