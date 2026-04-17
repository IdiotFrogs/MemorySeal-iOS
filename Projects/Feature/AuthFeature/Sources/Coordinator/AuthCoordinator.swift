//
//  AuthCoordinator.swift
//  AuthFeature
//
//  Created by 선민재 on 4/13/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import SplashFeature
import SignInFeature
import SignUpFeature

public final class AuthCoordinator {
    public struct Action {
        public let authDidFinish: () -> Void

        public init(authDidFinish: @escaping () -> Void) {
            self.authDidFinish = authDidFinish
        }
    }

    private let navigationController: UINavigationController
    private var splashCoordinator: SplashCoordinator?
    private let action: Action

    public init(with navigationController: UINavigationController, action: Action) {
        self.navigationController = navigationController
        self.action = action
    }

    public func start() {
        let splashAction = SplashCoordinator.Action(
            moveToSignIn: moveToSignInCoordinator,
            moveToHome: action.authDidFinish,
            moveToSignUp: moveToSignUpCoordinator
        )
        let coordinator = SplashCoordinator(with: navigationController, action: splashAction)
        splashCoordinator = coordinator
        coordinator.start()
    }

    private func moveToSignInCoordinator() {
        splashCoordinator = nil
        let signInAction = SignInCoordinator.Action(
            moveToHome: action.authDidFinish,
            moveToSignUp: moveToSignUpCoordinator
        )
        let coordinator = SignInCoordinator(with: navigationController, action: signInAction)
        coordinator.start()
    }

    private func moveToSignUpCoordinator() {
        let signUpAction = SignUpCoordinator.Action(
            moveToHome: action.authDidFinish
        )
        let coordinator = SignUpCoordinator(with: navigationController, action: signUpAction)
        coordinator.start()
    }
}
