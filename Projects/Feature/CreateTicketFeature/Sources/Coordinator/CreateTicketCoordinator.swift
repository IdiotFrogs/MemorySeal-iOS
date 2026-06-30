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
    private let didCreateTicket: () -> Void

    public init(
        with navigationController: UINavigationController,
        didCreateTicket: @escaping () -> Void
    ) {
        self.navigationController = navigationController
        self.didCreateTicket = didCreateTicket
    }

    public func start() {
        let action = CreateTicketViewModel.Action(
            popViewController: popViewController,
            didCreateTicket: didCreateTicket
        )
        let createTicketViewController = createTicketDIContainer.makeCreateTicketViewController(action: action)

        self.navigationController.pushViewController(
            createTicketViewController,
            animated: true
        )
    }

    private func popViewController() {
        self.navigationController.popViewController(animated: true)
    }
}
