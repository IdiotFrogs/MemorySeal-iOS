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
    public struct Action {
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
    private let action: Action

    public init(with navigationController: UINavigationController, action: Action) {
        self.navigationController = navigationController
        self.action = action
    }

    public func start() {
        let vmAction = SplashViewModel.Action(
            moveToSignIn: action.moveToSignIn,
            moveToHome: action.moveToHome,
            moveToSignUp: action.moveToSignUp
        )
        let splashViewController = splashDIContainer.makeSplashViewController(action: vmAction)

        navigationController.pushViewController(splashViewController, animated: false)
        navigationController.viewControllers = [splashViewController]
    }
}
