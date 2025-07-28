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
    private func makeMemoryViewModel() -> MemoryViewModel {
        return MemoryViewModel()
    }
    
    func makeMemoryViewController() -> MemoryViewController {
        return MemoryViewController(with: makeMemoryViewModel())
    }
}
