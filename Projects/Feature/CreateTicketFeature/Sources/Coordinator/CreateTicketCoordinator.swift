//
//  CreateTicketCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 5/30/25.
//

import UIKit

public final class CreateTicketCoordinator {
    private let navigationController: UINavigationController
    private let createTicketDIContainer: CreateTicketDIContainer = .init()
    
    public init(
        with navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let createTicketViewController = createTicketDIContainer.makeCreateTicketViewController()
        
        self.navigationController.pushViewController(
            createTicketViewController,
            animated: true
        )
    }
}
