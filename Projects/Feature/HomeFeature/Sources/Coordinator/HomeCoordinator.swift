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

    private var hostHomeViewModel: HomeViewModel?
    private var contributorHomeViewModel: HomeViewModel?
    private var homeTabmanViewModel: HomeTabmanViewModel?

    public init(with navigationController: UINavigationController, dependency: Dependency) {
        self.navigationController = navigationController
        self.dependency = dependency
    }

    public func refreshHome() {
        hostHomeViewModel?.refresh()
        contributorHomeViewModel?.refresh()
    }

    public func refreshProfile() {
        homeTabmanViewModel?.refresh()
    }

    public func start() {
        let tabmanAction = HomeTabmanViewModel.Action(
            moveToCreateTicket: dependency.moveToCreateTicket,
            moveToProfile: dependency.moveToProfile,
            moveToEnterTicket: moveToEnterTicket
        )

        let homeAction = HomeViewModel.Action(
            moveToTicket: dependency.moveToTicket,
            moveToOpenCapsule: dependency.moveToOpenCapsule
        )

        let hostHomeViewModel = homeDIContainer.makeHomeViewModel(action: homeAction, role: .host)
        self.hostHomeViewModel = hostHomeViewModel
        let hostHomeViewController = homeDIContainer.makeHomeViewController(with: hostHomeViewModel)

        let contributorHomeViewModel = homeDIContainer.makeHomeViewModel(action: homeAction, role: .contributor)
        self.contributorHomeViewModel = contributorHomeViewModel
        let contributorHomeViewController = homeDIContainer.makeHomeViewController(with: contributorHomeViewModel)

        let homeTabmanViewModel = homeDIContainer.makeHomeTabmanViewModel(action: tabmanAction)
        self.homeTabmanViewModel = homeTabmanViewModel
        let homeTabManViewController = homeDIContainer.makeHomeTabmanViewController(
            with: homeTabmanViewModel,
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
        let action = EnterTicketViewModel.Action(
            didJoinTicket: { [weak self] in
                self?.refreshHome()
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
