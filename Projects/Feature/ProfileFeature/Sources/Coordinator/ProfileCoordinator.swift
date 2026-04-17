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
    public struct Action {
        public let moveToBack: () -> Void
        public let didLogout: () -> Void

        public init(moveToBack: @escaping () -> Void, didLogout: @escaping () -> Void) {
            self.moveToBack = moveToBack
            self.didLogout = didLogout
        }
    }

    private let navigationController: UINavigationController
    private let profileDIContainer: ProfileDIContainer = .init()
    private let action: Action

    public init(with navigationController: UINavigationController, action: Action) {
        self.navigationController = navigationController
        self.action = action
    }

    public func start() {
        let profileAction = ProfileViewModel.Action(
            moveToBack: action.moveToBack,
            moveToEditProfile: moveToEditProfile,
            moveToSettings: moveToSettings
        )
        let profileViewController = profileDIContainer.makeProfileViewController(action: profileAction)
        self.navigationController.pushViewController(
            profileViewController,
            animated: true
        )
    }

    private func moveToEditProfile(nickname: String, profileImageUrl: String) {
        let editAction = EditProfileViewModel.Action(moveToBack: popViewController)
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
            moveToLogout: action.didLogout,
            moveToWithdrawal: action.didLogout
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
