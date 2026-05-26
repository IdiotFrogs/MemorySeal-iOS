import Foundation

import MemoryPresentation
import BaseData
import BaseDomain
import MemoryData
import MemoryDomain
import CalendarDomain

public final class MemoryDIContainer {
    private func makeMemoryViewModel(action: MemoryViewModel.Action, capsuleId: Int) -> MemoryViewModel {
        return MemoryViewModel(action: action, capsuleId: capsuleId)
    }

    func makeMemoryViewController(action: MemoryViewModel.Action, capsuleId: Int) -> MemoryViewController {
        return MemoryViewController(with: makeMemoryViewModel(action: action, capsuleId: capsuleId))
    }

    func makeAddMemberViewController(capsuleId: Int) -> AddMemberViewController {
        return AddMemberViewController(
            with: makeAddMemberViewModel(capsuleId: capsuleId)
        )
    }

    private func makeAddMemberViewModel(capsuleId: Int) -> AddMemberViewModel {
        let provider = DefaultProvider<AddMemberTargetType>()
        let repository = DefaultAddMemberRepository(provider: provider)
        let useCase = DefaultAddMemberUseCase(addMemberRepository: repository)
        return AddMemberViewModel(
            capsuleId: capsuleId,
            addMemberUseCase: useCase
        )
    }

    private func makeManageTicketViewModel(action: ManageTicketViewModel.Action, capsuleId: Int, ticketName: String) -> ManageTicketViewModel {
        let provider = DefaultProvider<ManageTicketTargetType>()
        let repository = DefaultManageTicketRepository(provider: provider)
        let useCase = DefaultManageTicketUseCase(manageTicketRepository: repository)
        return ManageTicketViewModel(
            action: action,
            capsuleId: capsuleId,
            ticketName: ticketName,
            manageTicketUseCase: useCase
        )
    }

    func makeManageTicketViewController(action: ManageTicketViewModel.Action, capsuleId: Int, ticketName: String) -> ManageTicketViewController {
        return ManageTicketViewController(with: makeManageTicketViewModel(action: action, capsuleId: capsuleId, ticketName: ticketName))
    }

    // MARK: - BuryTicket

    private func makeBuryTicketViewModel(action: BuryTicketViewModel.Action, capsuleId: Int) -> BuryTicketViewModel {
        let calendarUseCase = DefaultCalendarUseCase()
        let provider = DefaultProvider<BuryTicketTargetType>()
        let repository = DefaultBuryTicketRepository(provider: provider)
        let buryTicketUseCase = DefaultBuryTicketUseCase(buryTicketRepository: repository)
        return BuryTicketViewModel(
            action: action,
            capsuleId: capsuleId,
            calendarUseCase: calendarUseCase,
            buryTicketUseCase: buryTicketUseCase
        )
    }

    func makeBuryTicketViewController(action: BuryTicketViewModel.Action, capsuleId: Int) -> BuryTicketViewController {
        return BuryTicketViewController(with: makeBuryTicketViewModel(action: action, capsuleId: capsuleId))
    }

    // MARK: - MyMemoryMessages

    public func makeMyMemoryMessagesViewController(capsuleId: Int) -> MyMemoryMessagesViewController {
        let viewModel = makeMyMemoryMessagesViewModel(capsuleId: capsuleId)
        let textListVC = MyMemoryMessageListViewController(type: .text, viewModel: viewModel)
        let photoListVC = MyMemoryMessageListViewController(type: .photo, viewModel: viewModel)
        return MyMemoryMessagesViewController(
            viewControllers: [textListVC, photoListVC],
            with: viewModel
        )
    }

    private func makeMyMemoryMessagesViewModel(capsuleId: Int) -> MyMemoryMessagesViewModel {
        let provider = DefaultProvider<CapsuleContentTargetType>()
        let userDefaultStorage = DefaultUserDefaultStorage()
        let repository = DefaultCapsuleContentRepository(
            provider: provider,
            userDefaultStorage: userDefaultStorage
        )
        let useCase = DefaultCapsuleContentUseCase(capsuleContentRepository: repository)
        return MyMemoryMessagesViewModel(
            capsuleId: capsuleId,
            capsuleContentUseCase: useCase
        )
    }
}
