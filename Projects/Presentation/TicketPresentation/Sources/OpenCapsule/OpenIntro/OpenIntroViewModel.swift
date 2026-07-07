import Foundation
import RxSwift
import RxCocoa

public final class OpenIntroViewModel {
    private let disposeBag = DisposeBag()

    // MARK: - Action

    public struct Action {
        public let ticketDidTap: () -> Void

        public init(ticketDidTap: @escaping () -> Void) {
            self.ticketDidTap = ticketDidTap
        }
    }

    private let action: Action

    public init(action: Action) {
        self.action = action
    }

    // MARK: - Input / Output

    struct Input {
        let ticketDidTap: ControlEvent<Void>
    }

    struct Output {}

    func transform(_ input: Input) -> Output {
        input.ticketDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.ticketDidTap()
            })
            .disposed(by: disposeBag)

        return Output()
    }
}
