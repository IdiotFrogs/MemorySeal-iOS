//
//  AddMemberViewModel.swift
//  MemoryPresentation
//
//  Created by 선민재 on 11/17/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public final class AddMemberViewModel {
    private let disposeBag = DisposeBag()
    
    public init() {
        
    }
    
    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
    }
    
    struct Output {
        let memberList: PublishRelay<[String]>
    }
    
    func transform(_ input: Input) -> Output {
        let memberList: PublishRelay<[String]> = .init()
        
        input.rxViewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                memberList.accept([
                    "유저 1",
                    "유저 2",
                    "유저 3",
                    "유저 4",
                    "유저 5",
                    "유저 6",
                    "유저 7",
                    "유저 8"
                ])
            })
            .disposed(by: disposeBag)
        
        return .init(memberList: memberList)
    }
}
