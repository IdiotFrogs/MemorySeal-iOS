//
//  LoginCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 5/01/25.
//

import UIKit

import LoginPresentation

public protocol LoginCoordinatorDelegate: AnyObject {
    func startSignUp()
    func startHome()
}

public final class LoginCoordinator {
    private let navigationController: UINavigationController
    private let loginDIContainer: LoginDIContainer = LoginDIContainer()
    
    public var delegate: LoginCoordinatorDelegate?
    
    public init(
        with navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let loginViewModel: LoginViewModel = loginDIContainer.makeLoginViewModel()
        loginViewModel.delegate = self
        let loginViewController: LoginViewController = loginDIContainer.makeLoginViewController(with: loginViewModel)
        
        self.navigationController.pushViewController(
            loginViewController,
            animated: false
        )
        
        self.navigationController.viewControllers = [loginViewController]
    }
}

extension LoginCoordinator: LoginViewModelDelegate {
    public func moveToHome() {
        delegate?.startHome()
    }
    
    public func moveToSignUp() {
        delegate?.startSignUp()
    }
}
