import UIKit

import TicketPresentation
import BaseData
import BaseDomain

public final class TicketCoordinator {
    private let navigationController: UINavigationController
    private let capsuleId: Int
    private let ticketDIContainer: TicketDIContainer = .init()
    private let store: OpenedCapsuleStore
    private let didBuryTicket: () -> Void
    private var externalOnOpened: (() -> Void)?
    private var ticketImageUrl: String?
    private var ticketDetailViewModel: TicketDetailViewModel?

    public init(
        with navigationController: UINavigationController,
        capsuleId: Int,
        didBuryTicket: @escaping () -> Void
    ) {
        self.navigationController = navigationController
        self.capsuleId = capsuleId
        self.didBuryTicket = didBuryTicket
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
            moveToBuryTicket: moveToBuryTicket,
            moveToWatering: moveToWatering
        )
        let viewModel = ticketDIContainer.makeTicketDetailViewModel(
            action: ticketDetailAction,
            capsuleId: capsuleId
        )
        self.ticketDetailViewModel = viewModel
        return ticketDIContainer.makeTicketDetailViewController(with: viewModel)
    }

    // MARK: - OpenFlow

    public func startOpenFlow(ticketImageUrl: String? = nil, onOpened: (() -> Void)?) {
        self.externalOnOpened = onOpened
        self.ticketImageUrl = ticketImageUrl
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
        let viewController = ticketDIContainer.makeOpenIntroViewController(
            action: action,
            ticketImageUrl: ticketImageUrl
        )
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
        let viewController = ticketDIContainer.makeOpenConfirmViewController(
            action: action,
            ticketImageUrl: ticketImageUrl
        )
        self.navigationController.pushViewController(
            viewController,
            animated: false
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
            },
            didBuryTicket: { [weak self] in
                guard let self else { return }
                self.navigationController.presentedViewController?.dismiss(animated: true)
                self.ticketDetailViewModel?.refresh()
                self.didBuryTicket()
            }
        )
        let viewController = ticketDIContainer.makeBuryTicketViewController(
            action: buryAction,
            capsuleId: capsuleId
        )
        self.navigationController.present(viewController, animated: true)
    }

    public func moveToWatering() {
        let wateringAction = WateringViewModel.Action(
            moveToBack: { [weak self] in
                self?.navigationController.popViewController(animated: true)
            },
            moveToAllDays: { [weak self] in
                self?.moveToWateringAllDays()
            }
        )
        let viewController = ticketDIContainer.makeWateringViewController(
            action: wateringAction,
            capsuleId: capsuleId
        )
        self.navigationController.pushViewController(viewController, animated: true)
    }

    public func moveToWateringAllDays() {
        let allDaysAction = WateringAllDaysViewModel.Action(
            moveToBack: { [weak self] in
                self?.navigationController.popViewController(animated: true)
            }
        )
        let viewController = ticketDIContainer.makeWateringAllDaysViewController(
            action: allDaysAction,
            capsuleId: capsuleId
        )
        self.navigationController.pushViewController(viewController, animated: true)
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
