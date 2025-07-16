//
//  HomeTabmanViewModel.swift
//  HomePresentation
//
//  Created by 선민재 on 5/30/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

public protocol HomeTabmanViewModelDelegate: AnyObject {
    func moveToCreateTicket()
}

public final class HomeTabmanViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    public var delegate: HomeTabmanViewModelDelegate?
    
    public init() { }
    
    struct Input {
        let createTicketButtonDidTap: ControlEvent<Void>
    }
    
    struct Output {
        
    }
    
    func transform(_ input: Input) -> Output {
        input.createTicketButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.moveToCreateTicket()
            })
            .disposed(by: disposeBag)
        return Output()
    }
}
