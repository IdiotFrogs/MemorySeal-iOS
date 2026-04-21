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
import MemoryFeature

public final class MainCoordinator {
    public struct Action {
        public let didRequestLogout: () -> Void

        public init(didRequestLogout: @escaping () -> Void) {
            self.didRequestLogout = didRequestLogout
        }
    }

    private let navigationController: UINavigationController
    private var profileCoordinator: ProfileCoordinator?
    private var memoryCoordinator: MemoryCoordinator?
    private let action: Action

    public init(with navigationController: UINavigationController, action: Action) {
        self.navigationController = navigationController
        self.action = action
    }

    public func start() {
        let homeAction = HomeCoordinator.Action(
            moveToCreateTicket: moveToCreateTicketCoordinator,
            moveToProfile: moveToProfileCoordinator,
            moveToMemory: moveToMemoryCoordinator
        )
        let coordinator = HomeCoordinator(with: navigationController, action: homeAction)
        coordinator.start()
    }

    private func moveToProfileCoordinator() {
        let profileAction = ProfileCoordinator.Action(
            moveToBack: { [weak self] in
                self?.navigationController.popViewController(animated: true)
                self?.profileCoordinator = nil
            },
            didLogout: { [weak self] in
                self?.profileCoordinator = nil
                self?.action.didRequestLogout()
            }
        )
        let coordinator = ProfileCoordinator(with: navigationController, action: profileAction)
        profileCoordinator = coordinator
        coordinator.start()
    }

    private func moveToCreateTicketCoordinator() {
        let coordinator = CreateTicketCoordinator(with: navigationController)
        coordinator.start()
    }

    private func moveToMemoryCoordinator(capsuleId: Int) {
        let coordinator = MemoryCoordinator(with: navigationController, capsuleId: capsuleId)
        memoryCoordinator = coordinator
        coordinator.start()
    }
}
