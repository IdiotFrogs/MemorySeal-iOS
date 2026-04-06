//
//  HomeCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 5/19/25.
//

import UIKit

import HomePresentation
import BaseDomain

public protocol HomeCoordinatorDelegate: AnyObject {
    func moveToCreateTicket()
    func moveToProfile()
    func moveToMemory(capsuleId: Int)
}

public final class HomeCoordinator {
    private let navigationController: UINavigationController
    private let homeDIContainer: HomeDIContainer = .init()
    
    public var delegate: HomeCoordinatorDelegate?
    
    public init(
        with navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let homeTabmanViewModel = homeDIContainer.makeHomeTabmanViewModel()
        homeTabmanViewModel.delegate = self
        
        let hostHomeViewModel = homeDIContainer.makeHomeViewModel(role: .host)
        let hostHomeViewController = homeDIContainer.makeHomeViewController(
            viewModel: hostHomeViewModel
        )
        hostHomeViewModel.delegate = self
        
        let contributorHomeViewModel = homeDIContainer.makeHomeViewModel(role: .contributor)
        let contributorHomeViewController = homeDIContainer.makeHomeViewController(
            viewModel: contributorHomeViewModel
        )
        contributorHomeViewModel.delegate = self
        
        let homeTabManViewController: HomeTabmanViewController = homeDIContainer.makeHomeTabmanViewController(
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
}

extension HomeCoordinator: HomeTabmanViewModelDelegate {
    public func moveToEnterTicket() {
        let enterTicketViewModel = homeDIContainer.makeEnterTicketViewModel()
        let enterTicketViewController = homeDIContainer.makeEnterTicketViewController(
            viewModel: enterTicketViewModel
        )
        enterTicketViewController.modalPresentationStyle = .overFullScreen
        self.navigationController.present(
            enterTicketViewController,
            animated: true
        )
    }
    
    public func moveToProfile() {
        delegate?.moveToProfile()
    }
    
    public func moveToCreateTicket() {
        delegate?.moveToCreateTicket()
    }
}

extension HomeCoordinator: HomeViewModelDelegate {
    public func moveToMemory(capsuleId: Int) {
        delegate?.moveToMemory(capsuleId: capsuleId)
    }
}
