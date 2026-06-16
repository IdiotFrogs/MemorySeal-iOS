import UIKit

import TicketPresentation
import BaseData
import BaseDomain

public final class TicketCoordinator {
    private let navigationController: UINavigationController
    private let capsuleId: Int
    private let ticketDIContainer: TicketDIContainer = .init()

    public init(
        with navigationController: UINavigationController,
        capsuleId: Int
    ) {
        self.navigationController = navigationController
        self.capsuleId = capsuleId
    }

    public func start() {
        let ticketDetailAction = TicketDetailViewModel.Action(
            moveToAddMember: moveToAddMember,
            moveToManageTicket: moveToManageTicket,
            moveToMyTicketMessages: moveToMyTicketMessages,
            moveToBuryTicket: moveToBuryTicket
        )
        let ticketDetailViewController = ticketDIContainer.makeTicketDetailViewController(action: ticketDetailAction, capsuleId: capsuleId)

        self.navigationController.pushViewController(
            ticketDetailViewController,
            animated: true
        )
    }

    // MARK: - MemoryMessages

    public func startMemoryMessages() {
        let action = MemoryMessagesViewModel.Action(
            moveToBack: { [weak self] in
                self?.navigationController.popViewController(animated: true)
            }
        )
        let viewController = ticketDIContainer.makeMemoryMessagesViewController(action: action)
        self.navigationController.pushViewController(
            viewController,
            animated: true
        )
    }

    public func moveToBuryTicket() {
        let buryAction = BuryTicketViewModel.Action(
            dismiss: { [weak self] in
                self?.navigationController.presentedViewController?.dismiss(animated: true)
            }
        )
        let viewController = ticketDIContainer.makeBuryTicketViewController(
            action: buryAction,
            capsuleId: capsuleId
        )
        self.navigationController.present(viewController, animated: true)
    }

    public func moveToAddMember() {
        let viewController = ticketDIContainer.makeAddMemberViewController(capsuleId: capsuleId)
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
        let viewController = ticketDIContainer.makeManageTicketViewController(action: manageAction, capsuleId: capsuleId, ticketName: "티켓 이름")
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

    // MARK: - MyTicketMessages

    public func moveToMyTicketMessages() {
        let vc = ticketDIContainer.makeMyTicketMessagesViewController(capsuleId: capsuleId)
        navigationController.pushViewController(vc, animated: true)
    }
}
