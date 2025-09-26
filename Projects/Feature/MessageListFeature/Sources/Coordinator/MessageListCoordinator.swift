//
//  MessageListCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 5/30/25.
//

import UIKit

import MessageListPresentation

public final class MessageListCoordinator {
    private let navigationController: UINavigationController
    private let createTicketDIContainer: MessageListDIContainer = .init()
    
    public init(
        with navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let messageListViewController = createTicketDIContainer.makeMessageListViewController()
        
        self.navigationController.pushViewController(
            messageListViewController,
            animated: true
        )
    }
}
