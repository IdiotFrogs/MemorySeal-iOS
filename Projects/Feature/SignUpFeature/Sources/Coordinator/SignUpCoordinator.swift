//
//  SignUpCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 10/28/24.
//

import UIKit

import SignUpPresentation

public final class SignUpCoordinator {
    public struct Dependency {
        public let moveToHome: () -> Void

        public init(moveToHome: @escaping () -> Void) {
            self.moveToHome = moveToHome
        }
    }

    private let navigationController: UINavigationController
    private let signUpDIContainer: SignUpDIContainer = SignUpDIContainer()
    private let dependency: Dependency

    public init(with navigationController: UINavigationController, dependency: Dependency) {
        self.navigationController = navigationController
        self.dependency = dependency
    }

    public func start() {
        let vmAction = SignUpViewModel.Action(
            moveToHome: dependency.moveToHome
        )
        let signUpViewController = signUpDIContainer.makeSignUpViewController(action: vmAction)

        self.navigationController.navigationBar.isHidden = true
        self.navigationController.pushViewController(
            signUpViewController,
            animated: false
        )
    }
}
