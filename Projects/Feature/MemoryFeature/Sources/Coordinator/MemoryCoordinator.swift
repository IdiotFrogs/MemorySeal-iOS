//
//  MemoryCoordinator.swift
//  ProjectDescriptionHelpers
//
//  Created by 선민재 on 7/28/25.
//

import UIKit

import MemoryPresentation
import BaseData
import BaseDomain

public final class MemoryCoordinator {
    private let navigationController: UINavigationController
    private let capsuleId: Int
    private let memoryDIContainer: MemoryDIContainer = .init()

    public init(
        with navigationController: UINavigationController,
        capsuleId: Int
    ) {
        self.navigationController = navigationController
        self.capsuleId = capsuleId
    }

    public func start() {
        let memoryViewModel = memoryDIContainer.makeMemoryViewModel(capsuleId: capsuleId)
        memoryViewModel.delegate = self
        let memoryViewController = memoryDIContainer.makeMemoryViewController(
            viewModel: memoryViewModel
        )

        self.navigationController.pushViewController(
            memoryViewController,
            animated: true
        )
    }
}

extension MemoryCoordinator: MemoryViewModelDelegate {
    public func moveToAddMemeber() {
        let viewController = memoryDIContainer.makeAddMemberViewController(capsuleId: capsuleId)
        self.navigationController.pushViewController(
            viewController,
            animated: true
        )
    }
}
