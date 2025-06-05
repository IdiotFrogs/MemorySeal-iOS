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

public protocol CreateTicketViewModelDelegate: AnyObject {
    func popViewController()
}

public final class CreateTicketViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let calendarUseCase: CalendarUseCase
    
    public var delegate: CreateTicketViewModelDelegate?
    
    private let calendarDates: PublishRelay<[CalendarDateModel]> = .init()
    
    public init(
        calendarUseCase: CalendarUseCase
    ) {
        self.calendarUseCase = calendarUseCase
    }
        
    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let navigationViewBackButtonDidTap: ControlEvent<Void>
    }
    
    struct Output {
        let calendarDates: PublishRelay<[CalendarDateModel]>
    }
    
    func transform(_ input: Input) -> Output {
        
        input.rxViewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.requestCalendarDates()
            })
            .disposed(by: disposeBag)
        
        input.navigationViewBackButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.popViewController()
            })
            .disposed(by: disposeBag)
        
        return Output(
            calendarDates: calendarDates
        )
    }
}

extension CreateTicketViewModel {
    private func requestCalendarDates() {
        let calendarDates: [CalendarDateModel] = calendarUseCase.generateCalendarDates(for: Date().kstNow)
        
        self.calendarDates.accept(calendarDates)
    }
}
