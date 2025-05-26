//
//  HomeViewModel.swift
//  HomePresentation
//
//  Created by 선민재 on 5/26/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

public final class HomeViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let ticketList: PublishRelay<[String]> = .init()
    
    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
    }
    
    struct Output {
        let ticketList: PublishRelay<[String]>
    }
    
    func transform(_ input: Input) -> Output {
        
        input.rxViewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.ticketList.accept([
                    "dummy1",
                    "dummy2"
                ])
            })
            .disposed(by: disposeBag)
        
        return Output(ticketList: ticketList)
    }
    public init() {}
}
