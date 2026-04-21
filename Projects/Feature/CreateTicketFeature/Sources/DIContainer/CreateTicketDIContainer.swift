//
//  CreateTicketDIContainer.swift
//  AppFeature
//
//  Created by 선민재 on 5/1/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation

import CalendarDomain
import CreateTicketDomain
import CreateTicketData
import BaseData
import CreateTicketPresentation

public final class CreateTicketDIContainer {
    private func makeCalendarUseCase() -> CalendarUseCase {
        return DefaultCalendarUseCase()
    }

    private func makeCreateTicketProvider() -> DefaultProvider<CreateTicketTargetType> {
        return DefaultProvider<CreateTicketTargetType>()
    }

    private func makeCreateTicketRepository() -> CreateTicketRepository {
        return DefaultCreateTicketRepository(provider: makeCreateTicketProvider())
    }

    private func makeCreateTicketUseCase() -> CreateTicketUseCase {
        return DefaultCreateTicketUseCase(createTicketRepository: makeCreateTicketRepository())
    }

    private func makeCreateTicketViewModel(action: CreateTicketViewModel.Action) -> CreateTicketViewModel {
        return CreateTicketViewModel(
            calendarUseCase: makeCalendarUseCase(),
            createTicketUseCase: makeCreateTicketUseCase(),
            action: action
        )
    }

    func makeCreateTicketViewController(action: CreateTicketViewModel.Action) -> CreateTicketViewController {
        return CreateTicketViewController(with: makeCreateTicketViewModel(action: action))
    }
}
