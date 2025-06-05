//
//  CreateTicketViewModel.swift
//  HomePresentation
//
//  Created by 선민재 on 5/30/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

import CalendarDomain
import DesignSystem

public protocol CreateTicketViewModelDelegate: AnyObject {
    func popViewController()
}

public final class CreateTicketViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let calendarUseCase: CalendarUseCase
    
    public var delegate: CreateTicketViewModelDelegate?
//    private var currentMonth: Date = Date().kstNow
    
    private let currentMonth: BehaviorRelay<Date> = .init(value: Date().kstNow)
    private let calendarDates: PublishRelay<[CalendarDateModel]> = .init()
    
    public init(
        calendarUseCase: CalendarUseCase
    ) {
        self.calendarUseCase = calendarUseCase
    }
        
    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let navigationViewBackButtonDidTap: ControlEvent<Void>
        let previousMonthButtonDidTap: ControlEvent<Void>
        let nextMonthButtonDidTap: ControlEvent<Void>
    }
    
    struct Output {
        let currentMonth: BehaviorRelay<Date>
        let calendarDates: PublishRelay<[CalendarDateModel]>
    }
    
    func transform(_ input: Input) -> Output {
        
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
        
        return Output(
            currentMonth: currentMonth,
            calendarDates: calendarDates
        )
    }
}

extension CreateTicketViewModel {
    private func requestCalendarDates(date: Date) {
        let calendarDates: [CalendarDateModel] = calendarUseCase.generateCalendarDates(for: date)
        
        self.calendarDates.accept(calendarDates)
        self.currentMonth.accept(date)
    }
}
