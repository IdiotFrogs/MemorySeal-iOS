//
//  MessageListViewModel.swift
//  MessageListPresentation
//
//  Created by 선민재 on 9/22/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

public final class MessageListViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let userList: PublishRelay<[String]> = .init()
    
    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
    }
    
    struct Output {
        let userList: PublishRelay<[String]>
    }
    
    func transform(_ input: Input) -> Output {
        input.rxViewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.userList.accept(["삥빵뽕뽕", "뿡뿡뿡", "삥삥삥"])
            })
            .disposed(by: disposeBag)
        
        return Output(userList: userList)
    }
    
    public init() {
        
    }
}
