//
//  AppCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 9/26/24.
//

import UIKit

import LoginFeature
import SignUpFeature
import HomeFeature

public final class AppCoordinator {
    private let navigationController: UINavigationController
    
    public init(
        with navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    public func moveToLoginCoordinator() {
        let loginCoordinator: LoginCoordinator = LoginCoordinator(
            with: navigationController
        )
        loginCoordinator.delegate = self
        
        loginCoordinator.start()
    }
    
    public func moveToSignUpCoordinator() {
        let signUpCoordinator: SignUpCoordinator = SignUpCoordinator(with: navigationController)
        
        signUpCoordinator.start()
    }
    
    public func moveToHomeCoorinator() {
        let homeCoordinator: HomeCoordinator = HomeCoordinator(
            with: navigationController
        )
        
        homeCoordinator.start()
    }
}

extension AppCoordinator: LoginCoordinatorDelegate {
    public func startSignUp() {
        self.moveToSignUpCoordinator()
    }
    
    public func startHome() {
        self.moveToHomeCoorinator()
    }
}
