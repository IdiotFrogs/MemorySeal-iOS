//
//  SignUpCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 10/28/24.
//

import UIKit

import SignUpPresentation

public final class SignUpCoordinator {
    private let navigationController: UINavigationController
    
    public init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let signUpViewController: SignUpViewController = SignUpViewController()
        
        self.navigationController.navigationBar.isHidden = true
        self.navigationController.pushViewController(
            signUpViewController,
            animated: false
        )
    }
}
