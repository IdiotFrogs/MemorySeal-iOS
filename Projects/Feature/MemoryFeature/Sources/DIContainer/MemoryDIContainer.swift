//
//  MemoryDIContainer.swift
//  AppFeature
//
//  Created by 선민재 on 7/28/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation

import MemoryPresentation

public final class MemoryDIContainer {
    func makeMemoryViewModel() -> MemoryViewModel {
        return MemoryViewModel()
    }
    
    func makeMemoryViewController(
        viewModel: MemoryViewModel
    ) -> MemoryViewController {
        return MemoryViewController(with: viewModel)
    }
    
    func makeAddMemberViewController() -> AddMemberViewController {
        return AddMemberViewController(with: makeAddMemberViewModel())
    }
    
    private func makeAddMemberViewModel() -> AddMemberViewModel {
        return AddMemberViewModel()
    }
}
