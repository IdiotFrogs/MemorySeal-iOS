//
//  CreateTicketDIContainer.swift
//  AppFeature
//
//  Created by 선민재 on 5/1/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation

import MessageListPresentation

public final class MessageListDIContainer {
    func makeMessageListViewController() -> MessageListViewController {
        return MessageListViewController(with: makeMessageListViewModel())
    }
    
    private func makeMessageListViewModel() -> MessageListViewModel {
        return MessageListViewModel()
    }
}
