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
import CreateTicketFeature
import ProfileFeature
import MemoryFeature

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
        let profileCoordinator: ProfileCoordinator = ProfileCoordinator(
            with: navigationController
        )
        profileCoordinator.start()
    }
    
    public func moveToMemoryCoordinator() {
        let memoryCoordinator: MemoryCoordinator = MemoryCoordinator(
            with: navigationController
        )
        memoryCoordinator.start()
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
