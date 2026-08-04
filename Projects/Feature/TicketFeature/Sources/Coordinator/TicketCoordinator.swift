import UIKit

import TicketPresentation
import BaseData
import BaseDomain

public final class TicketCoordinator {
    private let navigationController: UINavigationController
    private let capsuleId: Int
    private let ticketDIContainer: TicketDIContainer = .init()
    private let store: OpenedCapsuleStore
    private var externalOnOpened: (() -> Void)?

    public init(
        with navigationController: UINavigationController,
        capsuleId: Int
    ) {
        self.navigationController = navigationController
        self.capsuleId = capsuleId
        self.store = ticketDIContainer.makeOpenedCapsuleStore()
    }

    public func start() {
        self.navigationController.pushViewController(
            makeTicketDetailViewController(),
            animated: true
        )
    }

    public func startMemberList() {
        let ticketDetailViewController = makeTicketDetailViewController()
        let addMemberViewController = ticketDIContainer.makeAddMemberViewController(capsuleId: capsuleId)

        self.navigationController.setViewControllers(
            navigationController.viewControllers + [ticketDetailViewController, addMemberViewController],
            animated: true
        )
    }

    private func makeTicketDetailViewController() -> TicketDetailViewController {
        let ticketDetailAction = TicketDetailViewModel.Action(
            moveToAddMember: moveToAddMember,
            moveToManageTicket: moveToManageTicket,
            moveToMyTicketMessages: moveToMyTicketMessages,
            moveToBuryTicket: moveToBuryTicket
        )
        return ticketDIContainer.makeTicketDetailViewController(action: ticketDetailAction, capsuleId: capsuleId)
    }

    // MARK: - OpenFlow

    public func startOpenFlow(onOpened: (() -> Void)?) {
        self.externalOnOpened = onOpened
        if store.isOpened(capsuleId: capsuleId) {
            startMemoryMessages()
        } else {
            startOpenIntro()
        }
    }

    public func startOpenIntro() {
        let action = OpenIntroViewModel.Action(
            ticketDidTap: { [weak self] in
                self?.startOpenConfirm()
            }
        )
        let viewController = ticketDIContainer.makeOpenIntroViewController(action: action)
        self.navigationController.pushViewController(
            viewController,
            animated: true
        )
    }

    public func startOpenConfirm() {
        let action = OpenConfirmViewModel.Action(
            confirmDidTap: { [weak self] in
                self?.startMemoryMessages()
            }
        )
        let viewController = ticketDIContainer.makeOpenConfirmViewController(action: action)
        self.navigationController.pushViewController(
            viewController,
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
        let onOpened: () -> Void = { [weak self] in
            guard let self else { return }
            self.store.markOpened(capsuleId: self.capsuleId)
            self.externalOnOpened?()
        }
        let viewController = ticketDIContainer.makeMemoryMessagesViewController(
            action: action,
            capsuleId: capsuleId,
            onOpened: onOpened
        )
        let baseViewControllers = navigationController.viewControllers.filter {
            !($0 is OpenIntroViewController) && !($0 is OpenConfirmViewController)
        }
        self.navigationController.setViewControllers(
            baseViewControllers + [viewController],
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
