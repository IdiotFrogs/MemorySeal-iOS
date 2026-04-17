//
//  MemoryDIContainer.swift
//  AppFeature
//
//  Created by 선민재 on 7/28/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation

import MemoryPresentation
import BaseData
import BaseDomain

public final class MemoryDIContainer {
    private func makeMemoryViewModel(action: MemoryViewModel.Action, capsuleId: Int) -> MemoryViewModel {
        return MemoryViewModel(action: action, capsuleId: capsuleId)
    }

    func makeMemoryViewController(action: MemoryViewModel.Action, capsuleId: Int) -> MemoryViewController {
        return MemoryViewController(with: makeMemoryViewModel(action: action, capsuleId: capsuleId))
    }

    func makeAddMemberViewController(capsuleId: Int) -> AddMemberViewController {
        return AddMemberViewController(
            with: makeAddMemberViewModel(capsuleId: capsuleId)
        )
    }

    private func makeAddMemberViewModel(capsuleId: Int) -> AddMemberViewModel {
        let provider = DefaultProvider<TimeCapsuleTargetType>()
        let repository = DefaultTimeCapsuleRepository(provider: provider)
        let useCase = DefaultTimeCapsuleUseCase(timeCapsuleRepository: repository)
        return AddMemberViewModel(
            capsuleId: capsuleId,
            timeCapsuleUseCase: useCase
        )
    }

    private func makeManageTicketViewModel(action: ManageTicketViewModel.Action, capsuleId: Int, ticketName: String) -> ManageTicketViewModel {
        let provider = DefaultProvider<TimeCapsuleTargetType>()
        let repository = DefaultTimeCapsuleRepository(provider: provider)
        let useCase = DefaultTimeCapsuleUseCase(timeCapsuleRepository: repository)
        return ManageTicketViewModel(
            action: action,
            capsuleId: capsuleId,
            ticketName: ticketName,
            timeCapsuleUseCase: useCase
        )
    }

    func makeManageTicketViewController(action: ManageTicketViewModel.Action, capsuleId: Int, ticketName: String) -> ManageTicketViewController {
        return ManageTicketViewController(with: makeManageTicketViewModel(action: action, capsuleId: capsuleId, ticketName: ticketName))
    }
}
