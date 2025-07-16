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
        let homeViewController: HomeTabmanViewController = homeDIContainer.makeHomeTabmanViewController(with: homeTabmanViewModel)
        
        self.navigationController.navigationBar.isHidden = true
        self.navigationController.setViewControllers(
            [homeViewController],
            animated: false
        )
    }
}

extension HomeCoordinator: HomeTabmanViewModelDelegate {
    public func moveToCreateTicket() {
        delegate?.moveToCreateTicket()
    }
}
