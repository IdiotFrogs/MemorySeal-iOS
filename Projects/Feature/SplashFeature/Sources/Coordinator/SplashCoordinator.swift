//
//  SplashCoordinator.swift
//  SplashFeature
//
//  Created by 선민재 on 3/19/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import SplashPresentation

public protocol SplashCoordinatorDelegate: AnyObject {
    func splashCoordinatorMoveToLogin()
    func splashCoordinatorMoveToHome()
    func splashCoordinatorMoveToSignUp()
}

public final class SplashCoordinator {
    private let navigationController: UINavigationController
    private let splashDIContainer: SplashDIContainer = SplashDIContainer()

    public weak var delegate: SplashCoordinatorDelegate?

    public init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func start() {
        let splashViewModel = splashDIContainer.makeSplashViewModel()
        splashViewModel.delegate = self
        let splashViewController = splashDIContainer.makeSplashViewController(with: splashViewModel)

        navigationController.pushViewController(splashViewController, animated: false)
        navigationController.viewControllers = [splashViewController]
    }
}

extension SplashCoordinator: SplashViewModelDelegate {
    public func moveToLogin() {
        delegate?.splashCoordinatorMoveToLogin()
    }

    public func moveToHome() {
        delegate?.splashCoordinatorMoveToHome()
    }

    public func moveToSignUp() {
        delegate?.splashCoordinatorMoveToSignUp()
    }
}
