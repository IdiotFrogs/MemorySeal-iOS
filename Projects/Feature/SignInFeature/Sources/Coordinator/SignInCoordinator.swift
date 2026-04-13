//
//  SignInCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 5/01/25.
//

import UIKit

import SignInPresentation

public protocol SignInCoordinatorDelegate: AnyObject {
    func startSignUp()
    func startHome()
}

public final class SignInCoordinator {
    private let navigationController: UINavigationController
    private let signInDIContainer: SignInDIContainer = SignInDIContainer()
    
    public var delegate: SignInCoordinatorDelegate?
    
    public init(
        with navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let signInViewModel: SignInViewModel = signInDIContainer.makeSignInViewModel()
        signInViewModel.delegate = self
        let signInViewController: SignInViewController = signInDIContainer.makeSignInViewController(with: signInViewModel)
        
        self.navigationController.pushViewController(
            signInViewController,
            animated: false
        )
        
        self.navigationController.viewControllers = [signInViewController]
    }
}

extension SignInCoordinator: SignInViewModelDelegate {
    public func moveToHome() {
        delegate?.startHome()
    }
    
    public func moveToSignUp() {
        delegate?.startSignUp()
    }
}
