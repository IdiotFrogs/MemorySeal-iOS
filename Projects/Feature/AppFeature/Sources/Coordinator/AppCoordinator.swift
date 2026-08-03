//
//  AppCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 9/26/24.
//

import UIKit

import AuthFeature
import MainFeature
import BaseDomain

public final class AppCoordinator {
    private let navigationController: UINavigationController
    private var authCoordinator: AuthCoordinator?
    private var mainCoordinator: MainCoordinator?
    private var pendingDestination: LandingDestination?

    public init(
        with navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }

    public func start(destination: LandingDestination? = nil) {
        pendingDestination = destination
        moveToAuthCoordinator()
    }

    public func handle(destination: LandingDestination) {
        guard let mainCoordinator else {
            pendingDestination = destination
            return
        }
        mainCoordinator.land(destination)
    }

    private func moveToAuthCoordinator() {
        let dependency = AuthCoordinator.Dependency(
            authDidFinish: { [weak self] in
                self?.authCoordinator = nil
                self?.moveToMainCoordinator()
            }
        )
        let coordinator = AuthCoordinator(with: navigationController, dependency: dependency)
        authCoordinator = coordinator
        coordinator.start()
    }

    private func moveToMainCoordinator() {
        let dependency = MainCoordinator.Dependency(
            didRequestLogout: { [weak self] in
                self?.mainCoordinator = nil
                self?.moveToAuthCoordinator()
            }
        )
        let coordinator = MainCoordinator(with: navigationController, dependency: dependency)
        mainCoordinator = coordinator
        coordinator.start()

        consumePendingDestination()
    }

    private func consumePendingDestination() {
        guard let destination = pendingDestination else { return }
        pendingDestination = nil
        mainCoordinator?.land(destination)
    }
}
