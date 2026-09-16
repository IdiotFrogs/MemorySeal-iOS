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
        public let moveToOpenCapsule: (_ capsuleId: Int, _ imageUrl: String?) -> Void

        public init(
            moveToCreateTicket: @escaping () -> Void,
            moveToProfile: @escaping () -> Void,
            moveToTicket: @escaping (_ capsuleId: Int) -> Void,
            moveToOpenCapsule: @escaping (_ capsuleId: Int, _ imageUrl: String?) -> Void
        ) {
            self.moveToCreateTicket = moveToCreateTicket
            self.moveToProfile = moveToProfile
            self.moveToTicket = moveToTicket
            self.moveToOpenCapsule = moveToOpenCapsule
        }
    }

    private let navigationController: UINavigationController
    private let homeDIContainer: HomeDIContainer = .init()
    private let dependency: Dependency

    private var homeViewModel: HomeViewModel?
    private var openedTicketViewModel: OpenedTicketViewModel?
    private var homeContainerViewModel: HomeContainerViewModel?

    public init(with navigationController: UINavigationController, dependency: Dependency) {
        self.navigationController = navigationController
        self.dependency = dependency
    }

    public func refreshHome() {
        homeViewModel?.refresh()
        openedTicketViewModel?.refresh()
    }

    public func refreshProfile() {
        homeContainerViewModel?.refresh()
    }

    public func start() {
        let containerAction = HomeContainerViewModel.Action(
            moveToCreateTicket: dependency.moveToCreateTicket,
            moveToProfile: dependency.moveToProfile,
            moveToEnterTicket: moveToEnterTicket
        )

        let homeAction = HomeViewModel.Action(
            moveToTicket: dependency.moveToTicket,
            moveToOpenCapsule: dependency.moveToOpenCapsule,
            moveToSeeAll: { _ in }
        )

        let homeViewModel = homeDIContainer.makeHomeViewModel(action: homeAction)
        self.homeViewModel = homeViewModel
        let homeViewController = homeDIContainer.makeHomeViewController(with: homeViewModel)

        let openedTicketAction = OpenedTicketViewModel.Action(
            moveToTicket: dependency.moveToTicket
        )

        let openedTicketViewModel = homeDIContainer.makeOpenedTicketViewModel(action: openedTicketAction)
        self.openedTicketViewModel = openedTicketViewModel
        let openedTicketViewController = homeDIContainer.makeOpenedTicketViewController(with: openedTicketViewModel)

        let homeContainerViewModel = homeDIContainer.makeHomeContainerViewModel(action: containerAction)
        self.homeContainerViewModel = homeContainerViewModel
        let homeContainerViewController = homeDIContainer.makeHomeContainerViewController(
            with: homeContainerViewModel,
            viewControllers: [
                homeViewController,
                openedTicketViewController
            ]
        )

        self.navigationController.navigationBar.isHidden = true
        self.navigationController.setViewControllers(
            [homeContainerViewController],
            animated: false
        )
    }

    private func moveToEnterTicket() {
        let action = EnterTicketViewModel.Action(
            didJoinTicket: { [weak self] capsuleId in
                guard let self else { return }
                self.refreshHome()
                self.navigationController.dismiss(animated: true) { [weak self] in
                    guard let capsuleId else { return }
                    self?.dependency.moveToTicket(capsuleId)
                }
            }
        )
        let enterTicketViewController = homeDIContainer.makeEnterTicketViewController(action: action)
        enterTicketViewController.modalPresentationStyle = .overFullScreen
        self.navigationController.present(
            enterTicketViewController,
            animated: true
        )
    }
}
