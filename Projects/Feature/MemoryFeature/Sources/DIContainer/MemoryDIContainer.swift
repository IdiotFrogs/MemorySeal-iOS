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
    func makeMemoryViewController() -> MemoryViewController {
        return MemoryViewController()
    }
}
