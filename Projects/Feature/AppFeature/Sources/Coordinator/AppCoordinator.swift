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
        let action = AuthCoordinator.Action(
            authDidFinish: { [weak self] in
                self?.authCoordinator = nil
                self?.moveToMainCoordinator()
            }
        )
        let coordinator = AuthCoordinator(with: navigationController, action: action)
        authCoordinator = coordinator
        coordinator.start()
    }

    private func moveToMainCoordinator() {
        let action = MainCoordinator.Action(
            didRequestLogout: { [weak self] in
                self?.mainCoordinator = nil
                self?.moveToAuthCoordinator()
            }
        )
        let coordinator = MainCoordinator(with: navigationController, action: action)
        mainCoordinator = coordinator
        coordinator.start()
    }
}
