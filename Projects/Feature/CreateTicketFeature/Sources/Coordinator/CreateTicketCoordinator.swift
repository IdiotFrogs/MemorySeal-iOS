//
//  CreateTicketCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 5/30/25.
//

import UIKit

import CreateTicketPresentation

public final class CreateTicketCoordinator {
    private let navigationController: UINavigationController
    private let createTicketDIContainer: CreateTicketDIContainer = .init()
    
    public init(
        with navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let createTicketViewModel = createTicketDIContainer.makeCreateTicketViewModel()
        createTicketViewModel.delegate = self
        let createTicketViewController = createTicketDIContainer.makeCreateTicketViewController(with: createTicketViewModel)
        
        self.navigationController.pushViewController(
            createTicketViewController,
            animated: true
        )
    }
    
    private func popCreateTicketViewController() {
        self.navigationController.popViewController(animated: true)
    }
}

extension CreateTicketCoordinator: CreateTicketViewModelDelegate {
    public func popViewController() {
        self.popCreateTicketViewController()
    }
}
