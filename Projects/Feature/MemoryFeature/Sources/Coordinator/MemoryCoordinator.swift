//
//  MemoryCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 7/28/25.
//

import UIKit

import MemoryPresentation

public final class MemoryCoordinator {
    private let navigationController: UINavigationController
    private let memoryDIContainer: MemoryDIContainer = .init()
    
    public init(
        with navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let memoryViewModel = memoryDIContainer.makeMemoryViewModel()
        memoryViewModel.delegate = self
        let memoryViewController = memoryDIContainer.makeMemoryViewController(
            viewModel: memoryViewModel
        )
        
        self.navigationController.pushViewController(
            memoryViewController,
            animated: true
        )
    }
}

extension MemoryCoordinator: MemoryViewModelDelegate {
    public func moveToAddMemeber() {
        let viewController = memoryDIContainer.makeAddMemberViewController()
        self.navigationController.pushViewController(
            viewController,
            animated: true
        )
    }
}
