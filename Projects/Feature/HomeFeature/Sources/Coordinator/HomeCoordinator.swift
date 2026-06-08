//
//  HomeCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 5/19/25.
//

import UIKit

import HomePresentation
import BaseDomain

public final class HomeCoordinator {
    public struct Dependency {
        public let moveToCreateTicket: () -> Void
        public let moveToProfile: () -> Void
        public let moveToTicket: (_ capsuleId: Int) -> Void

        public init(moveToCreateTicket: @escaping () -> Void, moveToProfile: @escaping () -> Void, moveToTicket: @escaping (_ capsuleId: Int) -> Void) {
            self.moveToCreateTicket = moveToCreateTicket
            self.moveToProfile = moveToProfile
            self.moveToTicket = moveToTicket
        }
    }

    private let navigationController: UINavigationController
    private let homeDIContainer: HomeDIContainer = .init()
    private let dependency: Dependency

    public init(with navigationController: UINavigationController, dependency: Dependency) {
        self.navigationController = navigationController
        self.dependency = dependency
    }

    public func start() {
        let tabmanAction = HomeTabmanViewModel.Action(
            moveToCreateTicket: dependency.moveToCreateTicket,
            moveToProfile: dependency.moveToProfile,
            moveToEnterTicket: moveToEnterTicket
        )

        let homeAction = HomeViewModel.Action(moveToTicket: dependency.moveToTicket)

        let hostHomeViewController = homeDIContainer.makeHomeViewController(action: homeAction, role: .host)
        let contributorHomeViewController = homeDIContainer.makeHomeViewController(action: homeAction, role: .contributor)

        let homeTabManViewController = homeDIContainer.makeHomeTabmanViewController(
            action: tabmanAction,
            viewControllers: [
                hostHomeViewController,
                contributorHomeViewController
            ]
        )

        self.navigationController.navigationBar.isHidden = true
        self.navigationController.setViewControllers(
            [homeTabManViewController],
            animated: false
        )
    }

    private func moveToEnterTicket() {
        let enterTicketViewController = homeDIContainer.makeEnterTicketViewController()
        enterTicketViewController.modalPresentationStyle = .overFullScreen
        self.navigationController.present(
            enterTicketViewController,
            animated: true
        )
    }
}
