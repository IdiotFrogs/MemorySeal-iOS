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
        let memoryViewController = memoryDIContainer.makeMemoryViewController()
        
        self.navigationController.pushViewController(
            memoryViewController,
            animated: true
        )
    }
}
