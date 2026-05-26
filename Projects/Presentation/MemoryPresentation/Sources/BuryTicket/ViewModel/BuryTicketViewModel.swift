import Foundation

import RxSwift
import RxCocoa

import CalendarDomain
import MemoryDomain
import DesignSystem

public final class BuryTicketViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    public struct Action {
        public let dismiss: () -> Void

        public init(dismiss: @escaping () -> Void) {
            self.dismiss = dismiss
        }
    }

    public let action: Action

    private let capsuleId: Int
    private let calendarUseCase: CalendarUseCase
    private let buryTicketUseCase: BuryTicketUseCase

    private let currentMonth: BehaviorRelay<Date> = .init(value: Date().kstNow)
    private let calendarDates: PublishRelay<[CalendarDateModel]> = .init()
    private let selectedDate: BehaviorRelay<Date?> = .init(value: nil)

    public init(
        action: Action,
        capsuleId: Int,
        calendarUseCase: CalendarUseCase,
        buryTicketUseCase: BuryTicketUseCase
    ) {
        self.action = action
        self.capsuleId = capsuleId
        self.calendarUseCase = calendarUseCase
        self.buryTicketUseCase = buryTicketUseCase
    }

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let previousMonthButtonDidTap: ControlEvent<Void>
        let nextMonthButtonDidTap: ControlEvent<Void>
        let didSelectDate: PublishRelay<Date>
        let cancelButtonDidTap: ControlEvent<Void>
        let buryButtonDidTap: ControlEvent<Void>
    }

    struct Output {
        let currentMonth: BehaviorRelay<Date>
        let calendarDates: PublishRelay<[CalendarDateModel]>
        let selectedDate: BehaviorRelay<Date?>
        let canBury: Driver<Bool>
        let isLoading: Driver<Bool>
        let errorMessage: Signal<String>
    }

    func transform(_ input: Input) -> Output {
        let isLoading = BehaviorRelay<Bool>(value: false)
        let errorMessage = PublishRelay<String>()

        input.rxViewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.requestCalendarDates(date: self.currentMonth.value)
            })
            .disposed(by: disposeBag)

        input.previousMonthButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                var calendar = Calendar(identifier: .gregorian)
                calendar.locale = Locale(identifier: "en_US")
                calendar.timeZone = TimeZone(abbreviation: "UTC") ?? .current
                if let previousMonth = calendar.date(byAdding: .month, value: -1, to: self.currentMonth.value) {
                    self.requestCalendarDates(date: previousMonth)
                }
            })
            .disposed(by: disposeBag)

        input.nextMonthButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                var calendar = Calendar(identifier: .gregorian)
                calendar.locale = Locale(identifier: "en_US")
                calendar.timeZone = TimeZone(abbreviation: "UTC") ?? .current
                if let nextMonth = calendar.date(byAdding: .month, value: 1, to: self.currentMonth.value) {
                    self.requestCalendarDates(date: nextMonth)
                }
            })
            .disposed(by: disposeBag)

        input.didSelectDate
            .bind(to: selectedDate)
            .disposed(by: disposeBag)

        input.cancelButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.dismiss()
            })
            .disposed(by: disposeBag)

        input.buryButtonDidTap
            .withLatestFrom(selectedDate)
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { (self, date) in
                guard isLoading.value == false else { return }
                isLoading.accept(true)
                Task {
                    do {
                        try await self.buryTicketUseCase.buryTimeCapsule(
                            capsuleId: self.capsuleId,
                            openedAt: date
                        )
                        await MainActor.run {
                            isLoading.accept(false)
                            self.action.dismiss()
                        }
                    } catch {
                        await MainActor.run {
                            isLoading.accept(false)
                            errorMessage.accept("티켓을 묻는 중 오류가 발생했습니다.")
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        let canBury = Observable
            .combineLatest(selectedDate, isLoading)
            .map { date, loading in
                date != nil && loading == false
            }
            .asDriver(onErrorJustReturn: false)

        return Output(
            currentMonth: currentMonth,
            calendarDates: calendarDates,
            selectedDate: selectedDate,
            canBury: canBury,
            isLoading: isLoading.asDriver(),
            errorMessage: errorMessage.asSignal()
        )
    }
}

extension BuryTicketViewModel {
    private func requestCalendarDates(date: Date) {
        let calendarDates: [CalendarDateModel] = calendarUseCase.generateCalendarDates(for: date)
        self.calendarDates.accept(calendarDates)
        self.currentMonth.accept(date)
    }
}
