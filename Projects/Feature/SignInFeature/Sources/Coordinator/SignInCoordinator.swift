//
//  SignInCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 5/01/25.
//

import UIKit

import SignInPresentation

public final class SignInCoordinator {
    public struct Action {
        public let moveToHome: () -> Void
        public let moveToSignUp: () -> Void

        public init(moveToHome: @escaping () -> Void, moveToSignUp: @escaping () -> Void) {
            self.moveToHome = moveToHome
            self.moveToSignUp = moveToSignUp
        }
    }

    private let navigationController: UINavigationController
    private let signInDIContainer: SignInDIContainer = SignInDIContainer()
    private let action: Action

    public init(with navigationController: UINavigationController, action: Action) {
        self.navigationController = navigationController
        self.action = action
    }

    public func start() {
        let vmAction = SignInViewModel.Action(
            moveToHome: action.moveToHome,
            moveToSignUp: action.moveToSignUp
        )
        let signInViewController = signInDIContainer.makeSignInViewController(action: vmAction)

        self.navigationController.pushViewController(
            signInViewController,
            animated: false
        )

        self.navigationController.viewControllers = [signInViewController]
    }
}
