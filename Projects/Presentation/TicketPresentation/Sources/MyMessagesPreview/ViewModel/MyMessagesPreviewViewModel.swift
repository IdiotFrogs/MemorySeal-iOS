import Foundation
import RxSwift
import RxCocoa

import BaseDomain
import TicketDomain

public final class MyMessagesPreviewViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    public struct Action {
        public let moveToBack: () -> Void

        public init(moveToBack: @escaping () -> Void) {
            self.moveToBack = moveToBack
        }
    }

    private static let selfDisplayName: String = "나"

    private let action: Action
    private let capsuleId: Int
    private let capsuleContentUseCase: CapsuleContentUseCase
    private let userUseCase: UserUseCase

    private let participantRelay: BehaviorRelay<MemoryParticipant?> = .init(value: nil)
    private let contentsRelay: BehaviorRelay<[MemoryMessageContent]> = .init(value: [])
    private let isLoadingRelay: BehaviorRelay<Bool> = .init(value: false)
    private let errorRelay: PublishRelay<Void> = .init()

    public init(
        action: Action,
        capsuleId: Int,
        capsuleContentUseCase: CapsuleContentUseCase,
        userUseCase: UserUseCase
    ) {
        self.action = action
        self.capsuleId = capsuleId
        self.capsuleContentUseCase = capsuleContentUseCase
        self.userUseCase = userUseCase
    }

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let retryDidTap: PublishRelay<Void>
        let backButtonDidTap: ControlEvent<Void>
    }

    struct Output {
        let participant: Driver<MemoryParticipant?>
        let contents: Driver<[MemoryMessageContent]>
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
            self.fetchPreview()
        })
        .disposed(by: disposeBag)

        input.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToBack()
            })
            .disposed(by: disposeBag)

        return Output(
            participant: participantRelay.asDriver(),
            contents: contentsRelay.asDriver(),
            isLoading: isLoadingRelay.asDriver(),
            showError: errorRelay.asSignal()
        )
    }
}

extension MyMessagesPreviewViewModel {
    private func fetchPreview() {
        isLoadingRelay.accept(true)
        Task { [weak self] in
            guard let self else { return }
            do {
                async let myContents = self.capsuleContentUseCase.fetchMyContents(capsuleId: self.capsuleId)
                async let userInfo = self.userUseCase.fetchUserInfo()
                let (contents, me) = try await (myContents, userInfo)

                await MainActor.run {
                    self.isLoadingRelay.accept(false)
                    self.participantRelay.accept(
                        MemoryParticipant(
                            id: me.id,
                            name: Self.selfDisplayName,
                            profileImageUrl: me.profileImageUrl
                        )
                    )
                    self.contentsRelay.accept(contents.map { Self.makeContent(from: $0) })
                }
            } catch {
                await MainActor.run {
                    self.isLoadingRelay.accept(false)
                    self.errorRelay.accept(())
                }
            }
        }
    }

    private static func makeContent(from content: CapsuleContent) -> MemoryMessageContent {
        switch content {
        case .text(_, let text):
            return .text(text)
        case .photo(_, let imageUrls):
            return .photo(imageUrls: imageUrls)
        }
    }
}
