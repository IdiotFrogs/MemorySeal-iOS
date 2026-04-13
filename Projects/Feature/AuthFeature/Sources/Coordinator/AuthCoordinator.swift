//
//  AuthCoordinator.swift
//  AuthFeature
//
//  Created by 선민재 on 4/13/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import SplashFeature
import SignInFeature
import SignUpFeature

public protocol AuthCoordinatorDelegate: AnyObject {
    func authDidFinish()
}

public final class AuthCoordinator {
    private let navigationController: UINavigationController
    private var splashCoordinator: SplashCoordinator?

    public weak var delegate: AuthCoordinatorDelegate?

    public init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func start() {
        let coordinator = SplashCoordinator(with: navigationController)
        coordinator.delegate = self
        splashCoordinator = coordinator
        coordinator.start()
    }

    private func moveToSignInCoordinator() {
        let coordinator = SignInCoordinator(with: navigationController)
        coordinator.delegate = self
        coordinator.start()
    }

    private func moveToSignUpCoordinator() {
        let coordinator = SignUpCoordinator(with: navigationController)
        coordinator.delegate = self
        coordinator.start()
    }
}

extension AuthCoordinator: SplashCoordinatorDelegate {
    public func splashCoordinatorMoveToSignIn() {
        splashCoordinator = nil
        moveToSignInCoordinator()
    }

    public func splashCoordinatorMoveToHome() {
        splashCoordinator = nil
        delegate?.authDidFinish()
    }

    public func splashCoordinatorMoveToSignUp() {
        splashCoordinator = nil
        moveToSignUpCoordinator()
    }
}

extension AuthCoordinator: SignInCoordinatorDelegate {
    public func startSignUp() {
        moveToSignUpCoordinator()
    }

    public func startHome() {
        delegate?.authDidFinish()
    }
}

extension AuthCoordinator: SignUpCoordinatorDelegate {}
