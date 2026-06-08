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
    public struct Dependency {
        public let authDidFinish: () -> Void

        public init(authDidFinish: @escaping () -> Void) {
            self.authDidFinish = authDidFinish
        }
    }

    private let navigationController: UINavigationController
    private var splashCoordinator: SplashCoordinator?
    private let dependency: Dependency

    public init(with navigationController: UINavigationController, dependency: Dependency) {
        self.navigationController = navigationController
        self.dependency = dependency
    }

    public func start() {
        let splashDependency = SplashCoordinator.Dependency(
            moveToSignIn: moveToSignInCoordinator,
            moveToHome: dependency.authDidFinish,
            moveToSignUp: moveToSignUpCoordinator
        )
        let coordinator = SplashCoordinator(with: navigationController, dependency: splashDependency)
        splashCoordinator = coordinator
        coordinator.start()
    }

    private func moveToSignInCoordinator() {
        splashCoordinator = nil
        let signInDependency = SignInCoordinator.Dependency(
            moveToHome: dependency.authDidFinish,
            moveToSignUp: moveToSignUpCoordinator
        )
        let coordinator = SignInCoordinator(with: navigationController, dependency: signInDependency)
        coordinator.start()
    }

    private func moveToSignUpCoordinator() {
        let signUpDependency = SignUpCoordinator.Dependency(
            moveToHome: dependency.authDidFinish
        )
        let coordinator = SignUpCoordinator(with: navigationController, dependency: signUpDependency)
        coordinator.start()
    }
}
