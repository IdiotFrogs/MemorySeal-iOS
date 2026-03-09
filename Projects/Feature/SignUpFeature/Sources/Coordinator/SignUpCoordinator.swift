//
//  SignUpCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 10/28/24.
//

import UIKit

import SignUpPresentation

public protocol SignUpCoordinatorDelegate: AnyObject {
    func startHome()
}

public final class SignUpCoordinator {
    private let navigationController: UINavigationController
    private let signUpDIContainer: SignUpDIContainer = SignUpDIContainer()

    public var delegate: SignUpCoordinatorDelegate?

    public init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func start() {
        let signUpViewModel = signUpDIContainer.makeSignUpViewModel()
        signUpViewModel.delegate = self

        let signUpViewController = signUpDIContainer.makeSignUpViewController(with: signUpViewModel)

        self.navigationController.navigationBar.isHidden = true
        self.navigationController.pushViewController(
            signUpViewController,
            animated: false
        )
    }
}

extension SignUpCoordinator: SignUpViewModelDelegate {
    public func moveToHome() {
        delegate?.startHome()
    }
}
