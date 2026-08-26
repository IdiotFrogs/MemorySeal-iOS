//
//  CreateTicketCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 5/30/25.
//

import UIKit

import CreateTicketPresentation

public final class CreateTicketCoordinator {
    public struct Dependency {
        public let moveToTicket: (_ capsuleId: Int) -> Void

        public init(moveToTicket: @escaping (_ capsuleId: Int) -> Void) {
            self.moveToTicket = moveToTicket
        }
    }

    private let navigationController: UINavigationController
    private let createTicketDIContainer: CreateTicketDIContainer = .init()
    private let dependency: Dependency

    public init(with navigationController: UINavigationController, dependency: Dependency) {
        self.navigationController = navigationController
        self.dependency = dependency
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

    private func didCreateTicket(capsuleId: Int) {
        self.navigationController.popViewController(animated: false)
        self.dependency.moveToTicket(capsuleId)
    }
}
