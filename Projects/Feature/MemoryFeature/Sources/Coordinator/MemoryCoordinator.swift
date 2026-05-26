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
            moveToManageTicket: moveToManageTicket,
            moveToMyMemoryMessages: moveToMyMemoryMessages
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
        let manageAction = ManageTicketViewModel.Action(
            didDeleteTimeCapsule: didDeleteTimeCapsule,
            didLeaveTimeCapsule: didLeaveTimeCapsule
        )
        let viewController = memoryDIContainer.makeManageTicketViewController(action: manageAction, capsuleId: capsuleId, ticketName: "티켓 이름")
        self.navigationController.pushViewController(
            viewController,
            animated: true
        )
    }

    public func didDeleteTimeCapsule() {
        self.navigationController.popToRootViewController(animated: true)
    }

    public func didLeaveTimeCapsule() {
        self.navigationController.popToRootViewController(animated: true)
    }

    // MARK: - MyMemoryMessages

    public func moveToMyMemoryMessages() {
        let vc = memoryDIContainer.makeMyMemoryMessagesViewController(capsuleId: capsuleId)
        navigationController.pushViewController(vc, animated: true)
    }
}
