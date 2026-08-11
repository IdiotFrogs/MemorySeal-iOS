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
        static let first: Int = 0
        static let size: Int = 10
        static let prefetchThreshold: Int = 3
    }

    private let action: Action
    private let capsuleId: Int
    private let wateringUseCase: WateringUseCase

    private let summary: BehaviorRelay<WateringEntity?> = .init(value: nil)
    private let days: BehaviorRelay<[WateringDayEntity]> = .init(value: [])
    private let errorToast: PublishRelay<String> = .init()

    private var nextPage: Int = Page.first
    private var isLastPage: Bool = false
    private var isLoading: Bool = false
    private var isWatering: Bool = false
    private var loadGeneration: Int = 0

    public init(
        action: Action,
        capsuleId: Int,
        wateringUseCase: WateringUseCase
    ) {
        self.action = action
        self.capsuleId = capsuleId
        self.wateringUseCase = wateringUseCase
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
                self.loadNextPageIfNeeded()
            })
            .disposed(by: disposeBag)

        input.prefetchItems
            .withUnretained(self)
            .subscribe(onNext: { (self, indexPaths) in
                let loadedCount = self.days.value.count
                let isNearEnd = indexPaths.contains {
                    $0.item >= loadedCount - Page.prefetchThreshold
                }
                guard isNearEnd else { return }
                self.loadNextPageIfNeeded()
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
            .filter { (self, _) in !self.isWateredToday(self.days.value) }
            .subscribe(onNext: { (self, _) in
                self.water()
            })
            .disposed(by: disposeBag)

        let state = Observable
            .combineLatest(summary, days)
            .share(replay: 1)

        let isWateredToday = state
            .withUnretained(self)
            .map { (self, state) in self.isWateredToday(state.1) }
            .asDriver(onErrorJustReturn: false)

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
            .withUnretained(self)
            .map { (self, state) in
                self.makeDayItems(state.1, totalDays: state.0?.totalDays ?? 0)
            }
            .asDriver(onErrorJustReturn: [])

        let todayIndex = dayItems
            .map { items in items.firstIndex(where: { $0.isToday }) ?? -1 }

        return Output(
            wateredDays: wateredDays,
            totalDays: totalDays,
            progressRatio: progressRatio,
            growthStage: growthStage,
            days: dayItems,
            todayIndex: todayIndex,
            isWateredToday: isWateredToday,
            errorToast: errorToast.asSignal()
        )
    }
}

extension WateringViewModel {
    private func loadNextPageIfNeeded() {
        guard !isLoading, !isLastPage else { return }
        isLoading = true

        let page = nextPage
        let generation = loadGeneration
        Task { [weak self] in
            guard let self else { return }
            do {
                let entity = try await self.wateringUseCase.fetchWaterings(
                    capsuleId: self.capsuleId,
                    page: page,
                    size: Page.size
                )
                await MainActor.run {
                    guard generation == self.loadGeneration else { return }
                    self.summary.accept(entity)
                    self.days.accept(page == Page.first ? entity.days : self.days.value + entity.days)
                    self.nextPage = page + 1
                    self.isLastPage = entity.isLast || entity.days.isEmpty
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    guard generation == self.loadGeneration else { return }
                    self.isLoading = false
                    self.errorToast.accept("물주기 정보를 불러올 수 없습니다")
                }
            }
        }
    }

    private func refresh() {
        loadGeneration += 1
        nextPage = Page.first
        isLastPage = false
        isLoading = false
        loadNextPageIfNeeded()
    }

    private func water() {
        guard !isWatering else { return }
        isWatering = true

        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.wateringUseCase.water(capsuleId: self.capsuleId)
                await MainActor.run {
                    self.isWatering = false
                    self.refresh()
                }
            } catch {
                await MainActor.run {
                    self.isWatering = false
                    self.errorToast.accept("물주기에 실패했습니다")
                }
            }
        }
    }

    private func todayEntity(_ days: [WateringDayEntity]) -> WateringDayEntity? {
        return days.first { day in
            guard let wateredDate = day.wateredDate else { return false }
            return Calendar.current.isDateInToday(wateredDate)
        }
    }

    private func isWateredToday(_ days: [WateringDayEntity]) -> Bool {
        return todayEntity(days)?.isWatered ?? false
    }

    private func makeDayItems(
        _ days: [WateringDayEntity],
        totalDays: Int
    ) -> [WateringDayItem] {
        guard totalDays > 0 else { return [] }

        return (0..<totalDays).map { index in
            guard index < days.count else {
                return WateringDayItem(isToday: false, state: .upcoming(day: index + 1))
            }

            let day = days[index]
            let isToday = day.wateredDate.map { Calendar.current.isDateInToday($0) } ?? false

            if day.isWatered {
                return WateringDayItem(
                    isToday: isToday,
                    state: .watered(profileImageUrl: day.profileImageUrl)
                )
            }
            return WateringDayItem(isToday: isToday, state: isToday ? .today : .missed)
        }
    }
}
