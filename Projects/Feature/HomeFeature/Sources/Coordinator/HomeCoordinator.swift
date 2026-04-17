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
    public struct Action {
        public let moveToCreateTicket: () -> Void
        public let moveToProfile: () -> Void
        public let moveToMemory: (_ capsuleId: Int) -> Void

        public init(moveToCreateTicket: @escaping () -> Void, moveToProfile: @escaping () -> Void, moveToMemory: @escaping (_ capsuleId: Int) -> Void) {
            self.moveToCreateTicket = moveToCreateTicket
            self.moveToProfile = moveToProfile
            self.moveToMemory = moveToMemory
        }
    }

    private let navigationController: UINavigationController
    private let homeDIContainer: HomeDIContainer = .init()
    private let action: Action

    public init(with navigationController: UINavigationController, action: Action) {
        self.navigationController = navigationController
        self.action = action
    }

    public func start() {
        let tabmanAction = HomeTabmanViewModel.Action(
            moveToCreateTicket: action.moveToCreateTicket,
            moveToProfile: action.moveToProfile,
            moveToEnterTicket: moveToEnterTicket
        )

        let homeAction = HomeViewModel.Action(moveToMemory: action.moveToMemory)

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
