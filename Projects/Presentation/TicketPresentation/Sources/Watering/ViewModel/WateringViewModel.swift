import Foundation
import RxSwift
import RxCocoa

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

    private let action: Action
    private let totalDays: Int
    private let pastWateredDays: Int

    private let isWateredToday: BehaviorRelay<Bool> = .init(value: false)

    private var todayIndex: Int {
        return min(pastWateredDays, max(totalDays - 1, 0))
    }

    public init(
        action: Action,
        wateredDays: Int = 25,
        totalDays: Int = 90
    ) {
        self.action = action
        self.totalDays = totalDays
        self.pastWateredDays = wateredDays
    }

    // MARK: - Input / Output

    struct Input {
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
    }

    func transform(_ input: Input) -> Output {
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
            .filter { (self, _) in !self.isWateredToday.value }
            .subscribe(onNext: { (self, _) in
                self.isWateredToday.accept(true)
            })
            .disposed(by: disposeBag)

        let totalDays = self.totalDays
        let pastWateredDays = self.pastWateredDays

        let wateredDays = isWateredToday
            .map { pastWateredDays + ($0 ? 1 : 0) }
            .asDriver(onErrorJustReturn: pastWateredDays)

        let progressRatio = wateredDays
            .map { days -> Double in
                guard totalDays > 0 else { return 0 }
                return min(Double(days) / Double(totalDays), 1)
            }

        let growthStage = wateredDays
            .map { WateringGrowthStage.stage(wateredDays: $0, totalDays: totalDays) }

        let days = isWateredToday
            .withUnretained(self)
            .map { (self, isWateredToday) in
                self.makeDayItems(isWateredToday: isWateredToday)
            }
            .asDriver(onErrorJustReturn: [])

        return Output(
            wateredDays: wateredDays,
            totalDays: .just(totalDays),
            progressRatio: progressRatio,
            growthStage: growthStage,
            days: days,
            todayIndex: .just(todayIndex),
            isWateredToday: isWateredToday.asDriver()
        )
    }
}

extension WateringViewModel {
    private func makeDayItems(isWateredToday: Bool) -> [WateringDayItem] {
        let todayIndex = self.todayIndex
        return (0..<totalDays).map { index in
            if index < todayIndex {
                return WateringDayItem(title: "\(index + 1)", isToday: false, isWatered: true)
            }
            if index == todayIndex {
                return WateringDayItem(title: "오늘", isToday: true, isWatered: isWateredToday)
            }
            return WateringDayItem(title: "\(index + 1)", isToday: false, isWatered: false)
        }
    }
}
