//
//  AppCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 9/26/24.
//

import UIKit

import LoginFeature
import SignUpFeature

public final class AppCoordinator {
    private let navigationController: UINavigationController
    
    public init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func moveToLoginCoordinator() {
        let loginCoordinator: LoginCoordinator = LoginCoordinator(with: navigationController)
        
        loginCoordinator.start()
    }
    
    public func moveToSignUpCoordinator() {
        let signUpCoordinator: SignUpCoordinator = SignUpCoordinator(with: navigationController)
        
        signUpCoordinator.start()
    }
}
