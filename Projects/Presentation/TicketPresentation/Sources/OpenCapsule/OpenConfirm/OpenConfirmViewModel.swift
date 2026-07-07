import Foundation
import RxSwift
import RxCocoa

public final class OpenConfirmViewModel {
    private let disposeBag = DisposeBag()

    // MARK: - Action

    public struct Action {
        public let confirmDidTap: () -> Void

        public init(confirmDidTap: @escaping () -> Void) {
            self.confirmDidTap = confirmDidTap
        }
    }

    private let action: Action

    public init(action: Action) {
        self.action = action
    }

    // MARK: - Input / Output

    struct Input {
        let confirmDidTap: ControlEvent<Void>
    }

    struct Output {}

    func transform(_ input: Input) -> Output {
        input.confirmDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.confirmDidTap()
            })
            .disposed(by: disposeBag)

        return Output()
    }
}
