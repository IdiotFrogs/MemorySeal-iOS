import Foundation

import TicketPresentation
import BaseData
import BaseDomain
import TicketData
import TicketDomain

public final class TicketDIContainer {
    private func makeTicketDetailViewModel(action: TicketDetailViewModel.Action, capsuleId: Int) -> TicketDetailViewModel {
        let detailProvider = DefaultProvider<TicketDetailTargetType>()
        let detailRepository = DefaultTicketDetailRepository(provider: detailProvider)
        let ticketDetailUseCase = DefaultTicketDetailUseCase(ticketDetailRepository: detailRepository)

        let addMemberProvider = DefaultProvider<AddMemberTargetType>()
        let addMemberRepository = DefaultAddMemberRepository(provider: addMemberProvider)
        let addMemberUseCase = DefaultAddMemberUseCase(addMemberRepository: addMemberRepository)

        return TicketDetailViewModel(
            action: action,
            capsuleId: capsuleId,
            ticketDetailUseCase: ticketDetailUseCase,
            addMemberUseCase: addMemberUseCase
        )
    }

    func makeTicketDetailViewController(action: TicketDetailViewModel.Action, capsuleId: Int) -> TicketDetailViewController {
        return TicketDetailViewController(with: makeTicketDetailViewModel(action: action, capsuleId: capsuleId))
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

    // MARK: - MyTicketMessages

    public func makeMyTicketMessagesViewController(capsuleId: Int) -> MyTicketMessagesViewController {
        let viewModel = makeMyTicketMessagesViewModel(capsuleId: capsuleId)
        let textListVC = MyTicketMessageListViewController(type: .text, viewModel: viewModel)
        let photoListVC = MyTicketMessageListViewController(type: .photo, viewModel: viewModel)
        return MyTicketMessagesViewController(
            viewControllers: [textListVC, photoListVC],
            with: viewModel
        )
    }

    private func makeMyTicketMessagesViewModel(capsuleId: Int) -> MyTicketMessagesViewModel {
        let provider = DefaultProvider<CapsuleContentTargetType>()
        let userDefaultStorage = DefaultUserDefaultStorage()
        let repository = DefaultCapsuleContentRepository(
            provider: provider,
            userDefaultStorage: userDefaultStorage
        )
        let useCase = DefaultCapsuleContentUseCase(capsuleContentRepository: repository)
        return MyTicketMessagesViewModel(
            capsuleId: capsuleId,
            capsuleContentUseCase: useCase
        )
    }
}
