//
//  AppCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 9/26/24.
//

import UIKit

import SplashFeature
import AuthFeature
import SignUpFeature
import HomeFeature
import CreateTicketFeature
import ProfileFeature
import MemoryFeature

public final class AppCoordinator {
    private let navigationController: UINavigationController
    private var splashCoordinator: SplashCoordinator?
    private var profileCoordinator: ProfileCoordinator?

    public init(
        with navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }

    public func start() {
        let coordinator = SplashCoordinator(with: navigationController)
        coordinator.delegate = self
        splashCoordinator = coordinator
        coordinator.start()
    }

    public func moveToLoginCoordinator() {
        let loginCoordinator: LoginCoordinator = LoginCoordinator(
            with: navigationController
        )
        loginCoordinator.delegate = self
        
        loginCoordinator.start()
    }
    
    public func moveToSignUpCoordinator() {
        let signUpCoordinator: SignUpCoordinator = SignUpCoordinator(
            with: navigationController
        )
        
        signUpCoordinator.delegate = self
        
        signUpCoordinator.start()
    }
    
    public func moveToHomeCoorinator() {
        let homeCoordinator: HomeCoordinator = HomeCoordinator(
            with: navigationController
        )
        homeCoordinator.delegate = self
        
        homeCoordinator.start()
    }
    
    public func moveToCreateTicketCoordinator() {
        let createTicketCoordinator: CreateTicketCoordinator = CreateTicketCoordinator(
            with: navigationController
        )
        createTicketCoordinator.start()
    }
    
    public func moveToProfileCoordinator() {
        let coordinator = ProfileCoordinator(with: navigationController)
        coordinator.delegate = self
        profileCoordinator = coordinator
        coordinator.start()
    }
    
    public func moveToMemoryCoordinator() {
        let memoryCoordinator: MemoryCoordinator = MemoryCoordinator(
            with: navigationController
        )
        memoryCoordinator.start()
    }
}

extension AppCoordinator: SplashCoordinatorDelegate {
    public func splashCoordinatorMoveToLogin() {
        splashCoordinator = nil
        moveToLoginCoordinator()
    }

    public func splashCoordinatorMoveToHome() {
        splashCoordinator = nil
        moveToHomeCoorinator()
    }

    public func splashCoordinatorMoveToSignUp() {
        splashCoordinator = nil
        moveToSignUpCoordinator()
    }
}

extension AppCoordinator: LoginCoordinatorDelegate, SignUpCoordinatorDelegate {
    public func startSignUp() {
        self.moveToSignUpCoordinator()
    }
    
    public func startHome() {
        self.moveToHomeCoorinator()
    }
}

extension AppCoordinator: ProfileCoordinatorDelegate {
    public func moveToBack() {
        navigationController.popViewController(animated: true)
        profileCoordinator = nil
    }

    public func profileCoordinatorDidLogout() {
        profileCoordinator = nil
        moveToLoginCoordinator()
    }
}

extension AppCoordinator: HomeCoordinatorDelegate {
    public func moveToMemory() {
        self.moveToMemoryCoordinator()
    }
    
    public func moveToProfile() {
        self.moveToProfileCoordinator()
    }
    
    public func moveToCreateTicket() {
        self.moveToCreateTicketCoordinator()
    }
}
