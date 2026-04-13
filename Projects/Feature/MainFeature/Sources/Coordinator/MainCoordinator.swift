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

public protocol MainCoordinatorDelegate: AnyObject {
    func mainDidRequestLogout()
}

public final class MainCoordinator {
    private let navigationController: UINavigationController
    private var profileCoordinator: ProfileCoordinator?
    private var memoryCoordinator: MemoryCoordinator?

    public weak var delegate: MainCoordinatorDelegate?

    public init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func start() {
        let coordinator = HomeCoordinator(with: navigationController)
        coordinator.delegate = self
        coordinator.start()
    }

    private func moveToProfileCoordinator() {
        let coordinator = ProfileCoordinator(with: navigationController)
        coordinator.delegate = self
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

extension MainCoordinator: HomeCoordinatorDelegate {
    public func moveToProfile() {
        moveToProfileCoordinator()
    }

    public func moveToCreateTicket() {
        moveToCreateTicketCoordinator()
    }

    public func moveToMemory(capsuleId: Int) {
        moveToMemoryCoordinator(capsuleId: capsuleId)
    }
}

extension MainCoordinator: ProfileCoordinatorDelegate {
    public func moveToBack() {
        navigationController.popViewController(animated: true)
        profileCoordinator = nil
    }

    public func profileCoordinatorDidLogout() {
        profileCoordinator = nil
        delegate?.mainDidRequestLogout()
    }
}
