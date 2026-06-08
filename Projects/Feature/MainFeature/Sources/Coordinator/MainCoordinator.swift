//
//  MainCoordinator.swift
//  MainFeature
//
//  Created by 선민재 on 4/13/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import HomeFeature
import ProfileFeature
import CreateTicketFeature
import TicketFeature

public final class MainCoordinator {
    public struct Dependency {
        public let didRequestLogout: () -> Void

        public init(didRequestLogout: @escaping () -> Void) {
            self.didRequestLogout = didRequestLogout
        }
    }

    private let navigationController: UINavigationController
    private var profileCoordinator: ProfileCoordinator?
    private var ticketCoordinator: TicketCoordinator?
    private let dependency: Dependency

    public init(with navigationController: UINavigationController, dependency: Dependency) {
        self.navigationController = navigationController
        self.dependency = dependency
    }

    public func start() {
        let homeDependency = HomeCoordinator.Dependency(
            moveToCreateTicket: moveToCreateTicketCoordinator,
            moveToProfile: moveToProfileCoordinator,
            moveToTicket: moveToTicketCoordinator
        )
        let coordinator = HomeCoordinator(with: navigationController, dependency: homeDependency)
        coordinator.start()
    }

    private func moveToProfileCoordinator() {
        let profileDependency = ProfileCoordinator.Dependency(
            moveToBack: { [weak self] in
                self?.navigationController.popViewController(animated: true)
                self?.profileCoordinator = nil
            },
            didLogout: { [weak self] in
                self?.profileCoordinator = nil
                self?.dependency.didRequestLogout()
            }
        )
        let coordinator = ProfileCoordinator(with: navigationController, dependency: profileDependency)
        profileCoordinator = coordinator
        coordinator.start()
    }

    private func moveToCreateTicketCoordinator() {
        let coordinator = CreateTicketCoordinator(with: navigationController)
        coordinator.start()
    }

    private func moveToTicketCoordinator(capsuleId: Int) {
        let coordinator = TicketCoordinator(with: navigationController, capsuleId: capsuleId)
        ticketCoordinator = coordinator
        coordinator.start()
    }
}
