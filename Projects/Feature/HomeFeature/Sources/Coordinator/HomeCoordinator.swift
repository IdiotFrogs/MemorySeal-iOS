//
//  HomeCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 5/19/25.
//

import UIKit

import HomePresentation

public final class HomeCoordinator {
    private let navigationController: UINavigationController
    private let homeDIContainer: HomeDIContainer = .init()
    
    public init(
        with navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let homeViewController: HomeTabmanViewController = homeDIContainer.makeHomeTabmanViewController()
        
        self.navigationController.navigationBar.isHidden = true
        self.navigationController.setViewControllers(
            [homeViewController],
            animated: false
        )
    }
}
