//
//  SplashCoordinator.swift
//  SplashFeature
//
//  Created by 선민재 on 3/19/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import SplashPresentation

public final class SplashCoordinator {
    public struct Dependency {
        public let moveToSignIn: () -> Void
        public let moveToHome: () -> Void
        public let moveToSignUp: () -> Void

        public init(moveToSignIn: @escaping () -> Void, moveToHome: @escaping () -> Void, moveToSignUp: @escaping () -> Void) {
            self.moveToSignIn = moveToSignIn
            self.moveToHome = moveToHome
            self.moveToSignUp = moveToSignUp
        }
    }

    private let navigationController: UINavigationController
    private let splashDIContainer: SplashDIContainer = SplashDIContainer()
    private let dependency: Dependency

    public init(with navigationController: UINavigationController, dependency: Dependency) {
        self.navigationController = navigationController
        self.dependency = dependency
    }

    public func start() {
        let vmAction = SplashViewModel.Action(
            moveToSignIn: dependency.moveToSignIn,
            moveToHome: dependency.moveToHome,
            moveToSignUp: dependency.moveToSignUp
        )
        let splashViewController = splashDIContainer.makeSplashViewController(action: vmAction)

        navigationController.pushViewController(splashViewController, animated: false)
        navigationController.viewControllers = [splashViewController]
    }
}
