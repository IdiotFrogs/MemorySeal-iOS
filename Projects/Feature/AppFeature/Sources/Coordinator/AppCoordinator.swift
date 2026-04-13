//
//  AppCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 9/26/24.
//

import UIKit

import AuthFeature
import MainFeature

public final class AppCoordinator {
    private let navigationController: UINavigationController
    private var authCoordinator: AuthCoordinator?
    private var mainCoordinator: MainCoordinator?

    public init(
        with navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }

    public func start() {
        moveToAuthCoordinator()
    }

    private func moveToAuthCoordinator() {
        let coordinator = AuthCoordinator(with: navigationController)
        coordinator.delegate = self
        authCoordinator = coordinator
        coordinator.start()
    }

    private func moveToMainCoordinator() {
        let coordinator = MainCoordinator(with: navigationController)
        coordinator.delegate = self
        mainCoordinator = coordinator
        coordinator.start()
    }
}

extension AppCoordinator: AuthCoordinatorDelegate {
    public func authDidFinish() {
        authCoordinator = nil
        moveToMainCoordinator()
    }
}

extension AppCoordinator: MainCoordinatorDelegate {
    public func mainDidRequestLogout() {
        mainCoordinator = nil
        moveToAuthCoordinator()
    }
}
