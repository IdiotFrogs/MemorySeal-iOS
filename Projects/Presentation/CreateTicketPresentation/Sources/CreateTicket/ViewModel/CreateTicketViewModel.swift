//
//  CreateTicketViewModel.swift
//  HomePresentation
//
//  Created by 선민재 on 5/30/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import CalendarDomain
import CreateTicketDomain
import DesignSystem

public protocol CreateTicketViewModelDelegate: AnyObject {
    func popViewController()
}

public final class CreateTicketViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let calendarUseCase: CalendarUseCase
    private let createTicketUseCase: CreateTicketUseCase

    public var delegate: CreateTicketViewModelDelegate?

    private var storedImage: UIImage?
    private var storedDate: Date = Date().kstNow

    private let currentMonth: BehaviorRelay<Date> = .init(value: Date().kstNow)
    private let calendarDates: PublishRelay<[CalendarDateModel]> = .init()

    public init(
        calendarUseCase: CalendarUseCase,
        createTicketUseCase: CreateTicketUseCase
    ) {
        self.calendarUseCase = calendarUseCase
        self.createTicketUseCase = createTicketUseCase
    }

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let navigationViewBackButtonDidTap: ControlEvent<Void>
        let previousMonthButtonDidTap: ControlEvent<Void>
        let nextMonthButtonDidTap: ControlEvent<Void>
        let createButtonDidTap: ControlEvent<Void>
        let titleText: ControlProperty<String?>
        let descriptionText: ControlProperty<String?>
        let selectedImage: PublishRelay<UIImage>
        let selectedDate: PublishRelay<Date>
    }

    struct Output {
        let currentMonth: BehaviorRelay<Date>
        let calendarDates: PublishRelay<[CalendarDateModel]>
        let isLoading: BehaviorRelay<Bool>
    }

    func transform(_ input: Input) -> Output {
        let isLoading = BehaviorRelay<Bool>(value: false)

        input.rxViewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.requestCalendarDates(date: Date().kstNow)
            })
            .disposed(by: disposeBag)

        input.navigationViewBackButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.popViewController()
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

        input.selectedImage
            .withUnretained(self)
            .subscribe(onNext: { (self, image) in
                self.storedImage = image
            })
            .disposed(by: disposeBag)

        input.selectedDate
            .withUnretained(self)
            .subscribe(onNext: { (self, date) in
                self.storedDate = date
            })
            .disposed(by: disposeBag)

        input.createButtonDidTap
            .withLatestFrom(Observable.combineLatest(
                input.titleText.asObservable(),
                input.descriptionText.asObservable()
            ))
            .withUnretained(self)
            .subscribe(onNext: { (self, args) in
                let (title, description) = args
                guard let title, !title.isEmpty else { return }
                guard let imageData = self.storedImage?.jpegData(compressionQuality: 0.8) else { return }
                let desc = description.flatMap { $0.isEmpty ? nil : $0 }
                self.requestCreateTicket(
                    title: title,
                    description: desc,
                    openedAt: self.storedDate,
                    mainImage: imageData,
                    isLoading: isLoading
                )
            })
            .disposed(by: disposeBag)

        return Output(
            currentMonth: currentMonth,
            calendarDates: calendarDates,
            isLoading: isLoading
        )
    }
}

extension CreateTicketViewModel {
    private func requestCalendarDates(date: Date) {
        let calendarDates: [CalendarDateModel] = calendarUseCase.generateCalendarDates(for: date)
        self.calendarDates.accept(calendarDates)
        self.currentMonth.accept(date)
    }

    private func requestCreateTicket(
        title: String,
        description: String?,
        openedAt: Date,
        mainImage: Data,
        isLoading: BehaviorRelay<Bool>
    ) {
        isLoading.accept(true)
        Task {
            do {
                try await createTicketUseCase.execute(
                    title: title,
                    description: description,
                    openedAt: openedAt,
                    mainImage: mainImage
                )
                await MainActor.run {
                    isLoading.accept(false)
                    self.delegate?.popViewController()
                }
            } catch {
                await MainActor.run {
                    isLoading.accept(false)
                }
            }
        }
    }
}
