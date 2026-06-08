//
//  SignInCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 5/01/25.
//

import UIKit

import SignInPresentation

public final class SignInCoordinator {
    public struct Dependency {
        public let moveToHome: () -> Void
        public let moveToSignUp: () -> Void

        public init(moveToHome: @escaping () -> Void, moveToSignUp: @escaping () -> Void) {
            self.moveToHome = moveToHome
            self.moveToSignUp = moveToSignUp
        }
    }

    private let navigationController: UINavigationController
    private let signInDIContainer: SignInDIContainer = SignInDIContainer()
    private let dependency: Dependency

    public init(with navigationController: UINavigationController, dependency: Dependency) {
        self.navigationController = navigationController
        self.dependency = dependency
    }

    public func start() {
        let vmAction = SignInViewModel.Action(
            moveToHome: dependency.moveToHome,
            moveToSignUp: dependency.moveToSignUp
        )
        let signInViewController = signInDIContainer.makeSignInViewController(action: vmAction)

        self.navigationController.pushViewController(
            signInViewController,
            animated: false
        )

        self.navigationController.viewControllers = [signInViewController]
    }
}
