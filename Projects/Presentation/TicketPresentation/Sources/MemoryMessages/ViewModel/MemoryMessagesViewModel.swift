import Foundation
import RxSwift
import RxCocoa

public final class MemoryMessagesViewModel {
    private let disposeBag = DisposeBag()

    private let conversationsRelay: BehaviorRelay<[MemoryConversation]>

    // MARK: - Action

    public struct Action {
        public let moveToBack: () -> Void

        public init(moveToBack: @escaping () -> Void) {
            self.moveToBack = moveToBack
        }
    }

    private let action: Action

    public init(action: Action) {
        self.action = action
        self.conversationsRelay = BehaviorRelay(value: MemoryMessageMock.conversations())
    }

    // MARK: - Input / Output

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let backButtonDidTap: ControlEvent<Void>
    }

    struct Output {
        let conversations: Driver<[MemoryConversation]>
    }

    func transform(_ input: Input) -> Output {
        input.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToBack()
            })
            .disposed(by: disposeBag)

        return Output(
            conversations: conversationsRelay.asDriver()
        )
    }
}
