//
//  CreateTicketDIContainer.swift
//  AppFeature
//
//  Created by 선민재 on 5/1/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation

import CreateTicketPresentation

public final class CreateTicketDIContainer {
    private func makeCreateTicketViewModel() -> CreateTicketViewModel {
        return CreateTicketViewModel()
    }
    
    public func makeCreateTicketViewController() -> CreateTicketViewController {
        return CreateTicketViewController(with: makeCreateTicketViewModel())
    }
}
