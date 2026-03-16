//
//  ProfileCoordinator.swift
//  ProfileFeature
//
//  Created by 선민재 on 3/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import ProfilePresentation

public protocol ProfileCoordinatorDelegate: AnyObject {
    func moveToBack()
}

public final class ProfileCoordinator {
    private let navigationController: UINavigationController
    private let profileDIContainer: ProfileDIContainer = .init()

    public var delegate: ProfileCoordinatorDelegate?

    public init(
        with navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }

    public func start() {
        let profileViewModel = profileDIContainer.makeProfileViewModel()
        profileViewModel.delegate = self
        let profileViewController = profileDIContainer.makeProfileViewController(
            with: profileViewModel
        )
        self.navigationController.pushViewController(
            profileViewController,
            animated: true
        )
    }
}

extension ProfileCoordinator: ProfileViewModelDelegate, EditProfileViewModelDelegate {
    public func moveToBack() {
        self.navigationController.popViewController(animated: true)
    }

    public func moveToEditProfile() {
        let editProfileViewModel = profileDIContainer.makeEditProfileViewModel()
        editProfileViewModel.delegate = self
        let editProfileViewController = profileDIContainer.makeEditProfileViewController(
            with: editProfileViewModel
        )
        self.navigationController.pushViewController(
            editProfileViewController,
            animated: true
        )
    }
}
