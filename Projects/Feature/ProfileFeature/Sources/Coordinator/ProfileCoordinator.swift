//
//  ProfileCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 7/16/25.
//

import UIKit

import ProfilePresentation

public final class ProfileCoordinator {
    private let navigationController: UINavigationController
    private let profileDIContainer: ProfileDIContainer = .init()
    
    public init(
        with navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let profileViewController = profileDIContainer.makeProfileViewController()
        self.navigationController.pushViewController(
            profileViewController,
            animated: true
        )
    }
}
