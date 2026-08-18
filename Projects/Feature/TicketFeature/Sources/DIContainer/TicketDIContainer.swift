import Foundation

import TicketPresentation
import BaseData
import BaseDomain
import TicketData
import TicketDomain

public final class TicketDIContainer {
    func makeTicketDetailViewModel(action: TicketDetailViewModel.Action, capsuleId: Int) -> TicketDetailViewModel {
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

    func makeTicketDetailViewController(with viewModel: TicketDetailViewModel) -> TicketDetailViewController {
        return TicketDetailViewController(with: viewModel)
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

        let detailProvider = DefaultProvider<TicketDetailTargetType>()
        let detailRepository = DefaultTicketDetailRepository(provider: detailProvider)
        let ticketDetailUseCase = DefaultTicketDetailUseCase(ticketDetailRepository: detailRepository)

        return AddMemberViewModel(
            capsuleId: capsuleId,
            addMemberUseCase: useCase,
            ticketDetailUseCase: ticketDetailUseCase
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

    // MARK: - Watering

    private func makeWateringViewModel(action: WateringViewModel.Action, capsuleId: Int) -> WateringViewModel {
        let provider = DefaultProvider<WateringTargetType>()
        let repository = DefaultWateringRepository(provider: provider)
        let useCase = DefaultWateringUseCase(wateringRepository: repository)
        return WateringViewModel(
            action: action,
            capsuleId: capsuleId,
            wateringUseCase: useCase
        )
    }

    func makeWateringViewController(action: WateringViewModel.Action, capsuleId: Int) -> WateringViewController {
        return WateringViewController(with: makeWateringViewModel(action: action, capsuleId: capsuleId))
    }

    private func makeWateringAllDaysViewModel(
        action: WateringAllDaysViewModel.Action,
        capsuleId: Int
    ) -> WateringAllDaysViewModel {
        let provider = DefaultProvider<WateringTargetType>()
        let repository = DefaultWateringRepository(provider: provider)
        let useCase = DefaultWateringUseCase(wateringRepository: repository)
        return WateringAllDaysViewModel(
            action: action,
            capsuleId: capsuleId,
            wateringUseCase: useCase
        )
    }

    func makeWateringAllDaysViewController(
        action: WateringAllDaysViewModel.Action,
        capsuleId: Int
    ) -> WateringAllDaysViewController {
        return WateringAllDaysViewController(
            with: makeWateringAllDaysViewModel(action: action, capsuleId: capsuleId)
        )
    }

    // MARK: - MyTicketMessages

    public func makeMyTicketMessagesViewController(
        action: MyTicketMessagesViewModel.Action,
        capsuleId: Int
    ) -> MyTicketMessagesViewController {
        let viewModel = makeMyTicketMessagesViewModel(action: action, capsuleId: capsuleId)
        let textListVC = MyTicketMessageListViewController(type: .text, viewModel: viewModel)
        let photoListVC = MyTicketMessageListViewController(type: .photo, viewModel: viewModel)
        return MyTicketMessagesViewController(
            viewControllers: [textListVC, photoListVC],
            with: viewModel
        )
    }

    // MARK: - OpenedCapsuleStore

    func makeOpenedCapsuleStore() -> OpenedCapsuleStore {
        return DefaultOpenedCapsuleStore()
    }

    // MARK: - MemoryMessages

    public func makeMemoryMessagesViewController(
        action: MemoryMessagesViewModel.Action,
        capsuleId: Int,
        onOpened: (() -> Void)?
    ) -> MemoryMessagesViewController {
        let provider = DefaultProvider<CapsuleContentTargetType>()
        let userDefaultStorage = DefaultUserDefaultStorage()
        let repository = DefaultCapsuleContentRepository(
            provider: provider,
            userDefaultStorage: userDefaultStorage
        )
        let useCase = DefaultCapsuleContentUseCase(capsuleContentRepository: repository)
        let currentUserId = repository.fetchCurrentUserId()
        let viewModel = MemoryMessagesViewModel(
            action: action,
            capsuleId: capsuleId,
            capsuleContentUseCase: useCase,
            currentUserId: currentUserId,
            onOpened: onOpened
        )
        return MemoryMessagesViewController(with: viewModel)
    }

    // MARK: - OpenCapsule

    public func makeOpenIntroViewController(
        action: OpenIntroViewModel.Action,
        ticketImageUrl: String?
    ) -> OpenIntroViewController {
        return OpenIntroViewController(
            with: OpenIntroViewModel(action: action, ticketImageUrl: ticketImageUrl)
        )
    }

    public func makeOpenConfirmViewController(
        action: OpenConfirmViewModel.Action,
        ticketImageUrl: String?
    ) -> OpenConfirmViewController {
        return OpenConfirmViewController(
            with: OpenConfirmViewModel(action: action, ticketImageUrl: ticketImageUrl)
        )
    }

    private func makeMyTicketMessagesViewModel(
        action: MyTicketMessagesViewModel.Action,
        capsuleId: Int
    ) -> MyTicketMessagesViewModel {
        let provider = DefaultProvider<CapsuleContentTargetType>()
        let userDefaultStorage = DefaultUserDefaultStorage()
        let repository = DefaultCapsuleContentRepository(
            provider: provider,
            userDefaultStorage: userDefaultStorage
        )
        let useCase = DefaultCapsuleContentUseCase(capsuleContentRepository: repository)
        return MyTicketMessagesViewModel(
            action: action,
            capsuleId: capsuleId,
            capsuleContentUseCase: useCase
        )
    }

    // MARK: - MyMessagesPreview

    private func makeUserUseCase() -> UserUseCase {
        let provider = DefaultProvider<UserTargetType>()
        let repository = DefaultUserRepository(
            provider: provider,
            userDefaultStorage: DefaultUserDefaultStorage(),
            keyChainStorage: DefaultKeyChainStorage()
        )
        return DefaultUserUseCase(userRepository: repository)
    }

    private func makeMyMessagesPreviewViewModel(
        action: MyMessagesPreviewViewModel.Action,
        capsuleId: Int
    ) -> MyMessagesPreviewViewModel {
        let provider = DefaultProvider<CapsuleContentTargetType>()
        let userDefaultStorage = DefaultUserDefaultStorage()
        let repository = DefaultCapsuleContentRepository(
            provider: provider,
            userDefaultStorage: userDefaultStorage
        )
        let useCase = DefaultCapsuleContentUseCase(capsuleContentRepository: repository)
        return MyMessagesPreviewViewModel(
            action: action,
            capsuleId: capsuleId,
            capsuleContentUseCase: useCase,
            userUseCase: makeUserUseCase()
        )
    }

    public func makeMyMessagesPreviewViewController(
        action: MyMessagesPreviewViewModel.Action,
        capsuleId: Int
    ) -> MyMessagesPreviewViewController {
        return MyMessagesPreviewViewController(
            with: makeMyMessagesPreviewViewModel(action: action, capsuleId: capsuleId)
        )
    }
}
