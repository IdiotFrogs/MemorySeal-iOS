//
//  LoginCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 5/01/25.
//

import UIKit

import LoginPresentation

public final class LoginCoordinator {
    private let navigationController: UINavigationController
    private let loginDIContainer: LoginDIContainer = LoginDIContainer()
    
    public init(
        with navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let loginViewController: LoginViewController = loginDIContainer.makeLoginViewController()
        
        self.navigationController.pushViewController(loginViewController, animated: false)
    }
}
