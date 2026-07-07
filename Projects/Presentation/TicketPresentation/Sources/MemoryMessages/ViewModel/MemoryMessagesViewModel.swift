import Foundation
import RxSwift
import RxCocoa

import TicketDomain

public final class MemoryMessagesViewModel {
    private let disposeBag = DisposeBag()

    private let capsuleId: Int
    private let capsuleContentUseCase: CapsuleContentUseCase
    private let currentUserId: Int?
    private let onOpened: (() -> Void)?

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
        currentUserId: Int?,
        onOpened: (() -> Void)?
    ) {
        self.action = action
        self.capsuleId = capsuleId
        self.capsuleContentUseCase = capsuleContentUseCase
        self.currentUserId = currentUserId
        self.onOpened = onOpened
    }

    // MARK: - Input / Output

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let retryDidTap: PublishRelay<Void>
        let backButtonDidTap: ControlEvent<Void>
    }

    struct Output {
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
            self.fetchConversations()
        })
        .disposed(by: disposeBag)

        input.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToBack()
            })
            .disposed(by: disposeBag)

        return Output(
            conversations: conversationsRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            showError: errorRelay.asSignal()
        )
    }

    private func fetchConversations() {
        isLoadingRelay.accept(true)
        Task { [weak self] in
            guard let self else { return }
            do {
                let groups = try await self.capsuleContentUseCase.fetchAllGroups(capsuleId: self.capsuleId)
                let conversations = groups.map { self.makeConversation(from: $0) }
                await MainActor.run {
                    self.isLoadingRelay.accept(false)
                    self.conversationsRelay.accept(conversations)
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
