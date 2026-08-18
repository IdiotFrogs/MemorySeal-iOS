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

    private let action: Action
    private let capsuleId: Int
    private let capsuleContentUseCase: CapsuleContentUseCase

    private let contentsRelay: BehaviorRelay<[PreviewMessageContent]> = .init(value: [])
    private let isLoadingRelay: BehaviorRelay<Bool> = .init(value: false)
    private let errorRelay: PublishRelay<Void> = .init()

    public init(
        action: Action,
        capsuleId: Int,
        capsuleContentUseCase: CapsuleContentUseCase
    ) {
        self.action = action
        self.capsuleId = capsuleId
        self.capsuleContentUseCase = capsuleContentUseCase
    }

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let retryDidTap: PublishRelay<Void>
        let backButtonDidTap: ControlEvent<Void>
    }

    struct Output {
        let contents: Driver<[PreviewMessageContent]>
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
                let contents = try await self.capsuleContentUseCase.fetchMyContents(capsuleId: self.capsuleId)

                await MainActor.run {
                    self.isLoadingRelay.accept(false)
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

    private static func makeContent(from content: CapsuleContent) -> PreviewMessageContent {
        switch content {
        case .text(_, let text):
            return .text(text)
        case .photo(_, let imageUrls):
            return .photo(imageUrls: imageUrls)
        }
    }
}
