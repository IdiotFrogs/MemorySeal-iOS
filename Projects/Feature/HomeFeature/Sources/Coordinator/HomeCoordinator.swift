//
//  HomeCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 5/19/25.
//

import UIKit

import HomePresentation

public protocol HomeCoordinatorDelegate: AnyObject {
    func moveToCreateTicket()
    func moveToProfile()
    func moveToMemory()
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
        let homeViewModel1 = homeDIContainer.makeHomeViewModel()
        let homeViewController1 = homeDIContainer.makeHomeViewController(
            viewModel: homeViewModel1
        )
        homeViewModel1.delegate = self
        let homeViewModel2 = homeDIContainer.makeHomeViewModel()
        let homeViewController2 = homeDIContainer.makeHomeViewController(
            viewModel: homeViewModel2
        )
        homeViewModel2.delegate = self
        let homeTabManViewController: HomeTabmanViewController = homeDIContainer.makeHomeTabmanViewController(
            with: homeTabmanViewModel,
            viewControllers: [
                homeViewController1,
                homeViewController2
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
    public func moveToProfile() {
        delegate?.moveToProfile()
    }
    
    public func moveToCreateTicket() {
        delegate?.moveToCreateTicket()
    }
}

extension HomeCoordinator: HomeViewModelDelegate {
    public func moveToMemory() {
        delegate?.moveToMemory()
    }
}
