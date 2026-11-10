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
    private enum Terms {
        static let urlString: String = "https://memoryseal.notion.site/3bc0cafca58580009a02f1fc5968ab63"
    }

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
            moveToTermsOfService: moveToTermsOfService,
            didLogout: dependency.didLogout,
            didWithdraw: dependency.didLogout
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

    private func popViewController() {
        self.navigationController.popViewController(animated: true)
    }

    private func moveToTermsOfService() {
        guard let url = URL(string: Terms.urlString) else { return }

        let viewController = profileDIContainer.makeTermsOfServiceViewController(
            url: url,
            moveToBack: popViewController
        )
        self.navigationController.pushViewController(
            viewController,
            animated: true
        )
    }
}
