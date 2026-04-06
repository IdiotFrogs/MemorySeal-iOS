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
    func makeMemoryViewModel(capsuleId: Int) -> MemoryViewModel {
        return MemoryViewModel(capsuleId: capsuleId)
    }

    func makeMemoryViewController(
        viewModel: MemoryViewModel
    ) -> MemoryViewController {
        return MemoryViewController(with: viewModel)
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
}
