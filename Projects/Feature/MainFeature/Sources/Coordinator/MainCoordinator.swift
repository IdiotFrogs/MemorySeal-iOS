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
import BaseDomain
import TicketDomain

public final class MainCoordinator {
    public struct Dependency {
        public let didRequestLogout: () -> Void

        public init(didRequestLogout: @escaping () -> Void) {
            self.didRequestLogout = didRequestLogout
        }
    }

    private let navigationController: UINavigationController
    private var homeCoordinator: HomeCoordinator?
    private var profileCoordinator: ProfileCoordinator?
    private var ticketCoordinator: TicketCoordinator?
    private var createTicketCoordinator: CreateTicketCoordinator?
    private let dependency: Dependency
    private let mainDIContainer: MainDIContainer = .init()
    private lazy var landingUseCase: LandingUseCase = mainDIContainer.makeLandingUseCase()

    public init(with navigationController: UINavigationController, dependency: Dependency) {
        self.navigationController = navigationController
        self.dependency = dependency
    }

    public func start() {
        let homeDependency = HomeCoordinator.Dependency(
            moveToCreateTicket: moveToCreateTicketCoordinator,
            moveToProfile: moveToProfileCoordinator,
            moveToTicket: moveToTicketCoordinator,
            moveToOpenCapsule: moveToOpenCapsuleCoordinator
        )
        let coordinator = HomeCoordinator(with: navigationController, dependency: homeDependency)
        homeCoordinator = coordinator
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
            },
            didEditProfile: { [weak self] in
                self?.homeCoordinator?.refreshProfile()
            },
            moveToTicket: { [weak self] capsuleId in
                self?.moveToTicketCoordinator(capsuleId: capsuleId)
            },
            moveToOpenCapsule: { [weak self] capsuleId, imageUrl in
                self?.moveToOpenCapsuleCoordinator(capsuleId: capsuleId, ticketImageUrl: imageUrl)
            }
        )
        let coordinator = ProfileCoordinator(with: navigationController, dependency: profileDependency)
        profileCoordinator = coordinator
        coordinator.start()
    }

    private func moveToCreateTicketCoordinator() {
        let coordinator = CreateTicketCoordinator(
            with: navigationController,
            didCreateTicket: { [weak self] in
                self?.homeCoordinator?.refreshHome()
            }
        )
        createTicketCoordinator = coordinator
        coordinator.start()
    }

    private func moveToTicketCoordinator(capsuleId: Int) {
        let coordinator = TicketCoordinator(with: navigationController, capsuleId: capsuleId)
        ticketCoordinator = coordinator
        coordinator.start()
    }

    private func moveToOpenCapsuleCoordinator(capsuleId: Int, ticketImageUrl: String? = nil) {
        let coordinator = TicketCoordinator(with: navigationController, capsuleId: capsuleId)
        ticketCoordinator = coordinator
        coordinator.startOpenFlow(ticketImageUrl: ticketImageUrl, onOpened: { [weak self] in
            self?.homeCoordinator?.refreshHome()
        })
    }

    private func moveToMemberListCoordinator(capsuleId: Int) {
        let coordinator = TicketCoordinator(with: navigationController, capsuleId: capsuleId)
        ticketCoordinator = coordinator
        coordinator.startMemberList()
    }

    // MARK: - Landing

    public func land(_ destination: LandingDestination) {
        Task { [weak self] in
            guard let self else { return }
            let resolution = await self.landingUseCase.resolve(destination)
            await MainActor.run {
                self.route(resolution, from: destination)
            }
        }
    }

    private func route(_ resolution: LandingResolution, from destination: LandingDestination) {
        if case .none = resolution { return }

        navigationController.popToRootViewController(animated: false)

        switch resolution {
        case .memberList(let capsuleId):
            moveToMemberListCoordinator(capsuleId: capsuleId)
        case .openCapsule(let capsuleId):
            moveToOpenCapsuleCoordinator(capsuleId: capsuleId)
        case .ticketDetail(let capsuleId):
            if case .invite = destination {
                homeCoordinator?.refreshHome()
            }
            moveToTicketCoordinator(capsuleId: capsuleId)
        case .none:
            break
        }
    }
}
