//
//  CreateTicketViewModel.swift
//  HomePresentation
//
//  Created by 선민재 on 5/30/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

public protocol CreateTicketViewModelDelegate: AnyObject {
    func popViewController()
}

public final class CreateTicketViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    
    public var delegate: CreateTicketViewModelDelegate?
    
    public init() {}
        
    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let navigationViewBackButtonDidTap: ControlEvent<Void>
    }
    
    struct Output {
        
    }
    
    func transform(_ input: Input) -> Output {
        
        input.navigationViewBackButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.popViewController()
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
}
