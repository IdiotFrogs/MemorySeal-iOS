import Foundation
import RxSwift
import RxCocoa

import TicketDomain

public final class MemoryMessagesViewModel {
    private let disposeBag = DisposeBag()

    private static let pageSize: Int = 10
    private static let singleUserPageSize: Int = 1

    private let capsuleId: Int
    private let capsuleContentUseCase: CapsuleContentUseCase
    private let addMemberUseCase: AddMemberUseCase
    private let currentUserId: Int?
    private let onOpened: (() -> Void)?

    private var groupOrder: [Int] = []
    private var groupsByUserId: [Int: CapsuleContentGroupEntity] = [:]
    private var contentPage: Int = 0
    private var isContentLast: Bool = false
    private var isFetchingContents: Bool = false

    private var collaborators: [CollaboratorEntity] = []
    private var collaboratorPage: Int = 0
    private var isCollaboratorLast: Bool = false
    private var isFetchingCollaborators: Bool = false

    private let participantsRelay: BehaviorRelay<[MemoryParticipant]> = .init(value: [])
    private let selectedIndexRelay: BehaviorRelay<Int?> = .init(value: nil)
    private let conversationsRelay: BehaviorRelay<[MemoryConversation]> = .init(value: [])
    private let isLoadingRelay: BehaviorRelay<Bool> = .init(value: false)
    private let errorRelay: PublishRelay<Void> = .init()

    // MARK: - Action

    public struct Action {
        public let moveToBack: () -> Void

        public init(moveToBack: @escaping () -> Void) {
            self.moveToBack = moveToBack
        }
    }

    private let action: Action

    public init(
        action: Action,
        capsuleId: Int,
        capsuleContentUseCase: CapsuleContentUseCase,
        addMemberUseCase: AddMemberUseCase,
        currentUserId: Int?,
        onOpened: (() -> Void)?
    ) {
        self.action = action
        self.capsuleId = capsuleId
        self.capsuleContentUseCase = capsuleContentUseCase
        self.addMemberUseCase = addMemberUseCase
        self.currentUserId = currentUserId
        self.onOpened = onOpened
    }

    // MARK: - Input / Output

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let retryDidTap: PublishRelay<Void>
        let backButtonDidTap: ControlEvent<Void>
        let feedDidReachBottom: PublishRelay<Void>
        let userListDidReachEnd: PublishRelay<Void>
        let userDidSelect: PublishRelay<Int>
    }

    struct Output {
        let participants: Driver<[MemoryParticipant]>
        let selectedIndex: Driver<Int?>
        let conversations: Driver<[MemoryConversation]>
        let isLoading: Driver<Bool>
        let showError: Signal<Void>
    }

    func transform(_ input: Input) -> Output {
        Observable.merge(
            input.rxViewDidLoad.asObservable(),
            input.retryDidTap.asObservable()
        )
        .withUnretained(self)
        .subscribe(onNext: { (self, _) in
            self.reload()
        })
        .disposed(by: disposeBag)

        input.feedDidReachBottom
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.fetchNextContentPage()
            })
            .disposed(by: disposeBag)

        input.userListDidReachEnd
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.fetchNextCollaboratorPage()
            })
            .disposed(by: disposeBag)

        input.userDidSelect
            .withUnretained(self)
            .subscribe(onNext: { (self, index) in
                self.selectUser(at: index)
            })
            .disposed(by: disposeBag)

        input.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToBack()
            })
            .disposed(by: disposeBag)

        return Output(
            participants: participantsRelay.asDriver(),
            selectedIndex: selectedIndexRelay.asDriver(),
            conversations: conversationsRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            showError: errorRelay.asSignal()
        )
    }
}

// MARK: - Reload

extension MemoryMessagesViewModel {
    private func reload() {
        groupOrder = []
        groupsByUserId = [:]
        contentPage = 0
        isContentLast = false
        collaborators = []
        collaboratorPage = 0
        isCollaboratorLast = false
        selectedIndexRelay.accept(nil)

        isLoadingRelay.accept(true)
        Task { [weak self] in
            guard let self else { return }
            do {
                async let contentPageResult = self.capsuleContentUseCase.fetchGroupPage(
                    capsuleId: self.capsuleId,
                    page: 0,
                    size: Self.pageSize
                )
                async let collaboratorPageResult = self.addMemberUseCase.fetchCollaborators(
                    capsuleId: self.capsuleId,
                    page: 0,
                    size: Self.pageSize
                )
                let (contents, members) = try await (contentPageResult, collaboratorPageResult)

                await MainActor.run {
                    self.isLoadingRelay.accept(false)
                    self.merge(page: contents)
                    self.appendCollaborators(page: members)
                    self.publishConversations()
                    self.onOpened?()
                }
            } catch {
                await MainActor.run {
                    self.isLoadingRelay.accept(false)
                    self.errorRelay.accept(())
                }
            }
        }
    }
}

// MARK: - Pagination

extension MemoryMessagesViewModel {
    private func fetchNextContentPage() {
        guard selectedIndexRelay.value == nil else { return }
        guard !isContentLast, !isFetchingContents else { return }

        isFetchingContents = true
        let nextPage = contentPage + 1

        Task { [weak self] in
            guard let self else { return }
            do {
                let page = try await self.capsuleContentUseCase.fetchGroupPage(
                    capsuleId: self.capsuleId,
                    page: nextPage,
                    size: Self.pageSize
                )
                await MainActor.run {
                    self.isFetchingContents = false
                    self.contentPage = nextPage
                    self.merge(page: page)
                    self.publishConversations()
                }
            } catch {
                await MainActor.run {
                    self.isFetchingContents = false
                    self.errorRelay.accept(())
                }
            }
        }
    }

    private func fetchNextCollaboratorPage() {
        guard !isCollaboratorLast, !isFetchingCollaborators else { return }

        isFetchingCollaborators = true
        let nextPage = collaboratorPage + 1

        Task { [weak self] in
            guard let self else { return }
            do {
                let page = try await self.addMemberUseCase.fetchCollaborators(
                    capsuleId: self.capsuleId,
                    page: nextPage,
                    size: Self.pageSize
                )
                await MainActor.run {
                    self.isFetchingCollaborators = false
                    self.collaboratorPage = nextPage
                    self.appendCollaborators(page: page)
                }
            } catch {
                await MainActor.run {
                    self.isFetchingCollaborators = false
                }
            }
        }
    }
}

// MARK: - Selection

extension MemoryMessagesViewModel {
    private func selectUser(at index: Int) {
        guard collaborators.indices.contains(index) else { return }

        if selectedIndexRelay.value == index {
            selectedIndexRelay.accept(nil)
            publishConversations()
            return
        }

        selectedIndexRelay.accept(index)

        let userId = collaborators[index].userId
        guard groupsByUserId[userId] == nil else {
            publishConversations()
            return
        }

        isLoadingRelay.accept(true)
        Task { [weak self] in
            guard let self else { return }
            do {
                let page = try await self.capsuleContentUseCase.fetchGroupPage(
                    capsuleId: self.capsuleId,
                    page: index,
                    size: Self.singleUserPageSize
                )
                await MainActor.run {
                    self.isLoadingRelay.accept(false)
                    self.merge(page: page)
                    self.publishConversations()
                }
            } catch {
                await MainActor.run {
                    self.isLoadingRelay.accept(false)
                    self.errorRelay.accept(())
                }
            }
        }
    }
}

// MARK: - Store

extension MemoryMessagesViewModel {
    private func merge(page: CapsuleContentGroupPageEntity) {
        isContentLast = page.isLast
        for group in page.groups {
            if groupsByUserId[group.userId] == nil {
                groupOrder.append(group.userId)
            }
            groupsByUserId[group.userId] = group
        }
    }

    private func appendCollaborators(page: CollaboratorPageEntity) {
        isCollaboratorLast = page.isLast
        collaborators.append(contentsOf: page.collaborators)
        participantsRelay.accept(collaborators.map { Self.makeParticipant(from: $0) })
    }

    private func publishConversations() {
        let userIds: [Int]
        if let index = selectedIndexRelay.value, collaborators.indices.contains(index) {
            userIds = [collaborators[index].userId]
        } else {
            userIds = groupOrder
        }

        let conversations = userIds
            .compactMap { groupsByUserId[$0] }
            .map { makeConversation(from: $0) }

        conversationsRelay.accept(conversations)
    }
}

// MARK: - Mapping

extension MemoryMessagesViewModel {
    private static func makeParticipant(from collaborator: CollaboratorEntity) -> MemoryParticipant {
        return MemoryParticipant(
            id: collaborator.userId,
            name: collaborator.nickname,
            profileImageUrl: collaborator.profileImageUrl
        )
    }

    private func makeConversation(from group: CapsuleContentGroupEntity) -> MemoryConversation {
        let isMine = group.userId == currentUserId
        let participant = MemoryParticipant(
            id: group.userId,
            name: group.nickname,
            profileImageUrl: group.profileImageUrl
        )
        let messages = group.contents.map { content -> MemoryMessage in
            switch content {
            case .text(_, let text):
                return MemoryMessage(content: .text(text), isMine: isMine)
            case .photo(_, let imageUrls):
                return MemoryMessage(content: .photo(imageUrls: imageUrls), isMine: isMine)
            }
        }
        return MemoryConversation(participant: participant, isMine: isMine, messages: messages)
    }
}
