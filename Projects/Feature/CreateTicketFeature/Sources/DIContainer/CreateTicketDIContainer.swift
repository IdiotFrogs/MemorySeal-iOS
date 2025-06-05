//
//  CreateTicketDIContainer.swift
//  AppFeature
//
//  Created by 선민재 on 5/1/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation

import CalendarDomain
import CreateTicketPresentation

public final class CreateTicketDIContainer {
    private func makeCalendarUseCase() -> CalendarUseCase {
        return DefaultCalendarUseCase()
    }
    
    func makeCreateTicketViewModel() -> CreateTicketViewModel {
        return CreateTicketViewModel(calendarUseCase: makeCalendarUseCase())
    }
    
    func makeCreateTicketViewController(
        with viewModel: CreateTicketViewModel
    ) -> CreateTicketViewController {
        return CreateTicketViewController(with: viewModel)
    }
}
