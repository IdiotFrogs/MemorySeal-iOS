import Foundation
import RxSwift
import RxCocoa

import TicketDomain

public final class WateringViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: - Action

    public struct Action {
        public let moveToBack: () -> Void
        public let moveToAllDays: () -> Void

        public init(
            moveToBack: @escaping () -> Void,
            moveToAllDays: @escaping () -> Void
        ) {
            self.moveToBack = moveToBack
            self.moveToAllDays = moveToAllDays
        }
    }

    private enum Page {
        static let size: Int = 10
    }

    private let action: Action
    private let store: WateringStore

    public init(
        action: Action,
        capsuleId: Int,
        wateringUseCase: WateringUseCase
    ) {
        self.action = action
        self.store = WateringStore(
            capsuleId: capsuleId,
            wateringUseCase: wateringUseCase,
            pageSize: Page.size
        )
    }

    // MARK: - Input / Output

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let prefetchItems: PublishRelay<[IndexPath]>
        let backButtonDidTap: ControlEvent<Void>
        let allDaysDidTap: ControlEvent<Void>
        let waterButtonDidTap: ControlEvent<Void>
    }

    struct Output {
        let wateredDays: Driver<Int>
        let totalDays: Driver<Int>
        let progressRatio: Driver<Double>
        let growthStage: Driver<WateringGrowthStage>
        let days: Driver<[WateringDayItem]>
        let todayIndex: Driver<Int>
        let isWateredToday: Driver<Bool>
        let errorToast: Signal<String>
    }

    func transform(_ input: Input) -> Output {
        input.rxViewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.store.loadNextPageIfNeeded()
            })
            .disposed(by: disposeBag)

        input.prefetchItems
            .withUnretained(self)
            .subscribe(onNext: { (self, indexPaths) in
                self.store.loadNextPageIfNeeded(prefetching: indexPaths)
            })
            .disposed(by: disposeBag)

        input.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToBack()
            })
            .disposed(by: disposeBag)

        input.allDaysDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToAllDays()
            })
            .disposed(by: disposeBag)

        input.waterButtonDidTap
            .withUnretained(self)
            .filter { (self, _) in !self.store.isWateredToday }
            .subscribe(onNext: { (self, _) in
                self.store.water()
            })
            .disposed(by: disposeBag)

        let state = Observable
            .combineLatest(store.summary, store.days)
            .share(replay: 1)

        let wateredDays = state
            .map { $0.0?.wateringCount ?? 0 }
            .asDriver(onErrorJustReturn: 0)

        let totalDays = state
            .map { $0.0?.totalDays ?? 0 }
            .asDriver(onErrorJustReturn: 0)

        let progressRatio = Driver
            .combineLatest(wateredDays, totalDays)
            .map { watered, total -> Double in
                guard total > 0 else { return 0 }
                return min(Double(watered) / Double(total), 1)
            }

        let growthStage = state
            .map { WateringGrowthStage.stage(serverStage: $0.0?.stage ?? 0) }
            .asDriver(onErrorJustReturn: .sprout)

        let dayItems = state
            .map { summary, days in
                WateringDayItemBuilder.makeItems(days: days, totalDays: summary?.totalDays ?? 0)
            }
            .asDriver(onErrorJustReturn: [])

        let todayIndex = dayItems
            .map { items in items.firstIndex(where: { $0.isToday }) ?? -1 }

        let isWateredToday = state
            .map { WateringDayItemBuilder.isWateredToday($0.1) }
            .asDriver(onErrorJustReturn: false)

        return Output(
            wateredDays: wateredDays,
            totalDays: totalDays,
            progressRatio: progressRatio,
            growthStage: growthStage,
            days: dayItems,
            todayIndex: todayIndex,
            isWateredToday: isWateredToday,
            errorToast: store.errorToast.asSignal()
        )
    }
}
