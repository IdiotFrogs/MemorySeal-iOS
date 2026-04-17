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
        let memoryAction = MemoryViewModel.Action(
            moveToAddMember: moveToAddMember,
            moveToManageTicket: moveToManageTicket
        )
        let memoryViewController = memoryDIContainer.makeMemoryViewController(action: memoryAction, capsuleId: capsuleId)

        self.navigationController.pushViewController(
            memoryViewController,
            animated: true
        )
    }

    public func moveToAddMember() {
        let viewController = memoryDIContainer.makeAddMemberViewController(capsuleId: capsuleId)
        self.navigationController.pushViewController(
            viewController,
            animated: true
        )
    }

    public func moveToManageTicket() {
        // TODO: ticketName은 추후 디테일 API 연동 시 실제 값으로 교체
        let manageAction = ManageTicketViewModel.Action(didDeleteTimeCapsule: didDeleteTimeCapsule)
        let viewController = memoryDIContainer.makeManageTicketViewController(action: manageAction, capsuleId: capsuleId, ticketName: "티켓 이름")
        self.navigationController.pushViewController(
            viewController,
            animated: true
        )
    }

    public func didDeleteTimeCapsule() {
        self.navigationController.popToRootViewController(animated: true)
    }
}
