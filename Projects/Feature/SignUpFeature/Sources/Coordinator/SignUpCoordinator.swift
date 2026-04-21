//
//  SignUpCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 10/28/24.
//

import UIKit

import SignUpPresentation

public final class SignUpCoordinator {
    public struct Action {
        public let moveToHome: () -> Void

        public init(moveToHome: @escaping () -> Void) {
            self.moveToHome = moveToHome
        }
    }

    private let navigationController: UINavigationController
    private let signUpDIContainer: SignUpDIContainer = SignUpDIContainer()
    private let action: Action

    public init(with navigationController: UINavigationController, action: Action) {
        self.navigationController = navigationController
        self.action = action
    }

    public func start() {
        let vmAction = SignUpViewModel.Action(
            moveToHome: action.moveToHome
        )
        let signUpViewController = signUpDIContainer.makeSignUpViewController(action: vmAction)

        self.navigationController.navigationBar.isHidden = true
        self.navigationController.pushViewController(
            signUpViewController,
            animated: false
        )
    }
}
