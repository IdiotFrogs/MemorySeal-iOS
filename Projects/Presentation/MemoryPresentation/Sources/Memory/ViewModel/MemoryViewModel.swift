//
//  MemoryViewModel.swift
//  MemoryPresentation
//
//  Created by 선민재 on 7/28/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

public protocol MemoryViewModelDelegate: AnyObject {
    func moveToAddMemeber()
}

public final class MemoryViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    
    public var delegate: MemoryViewModelDelegate?
    
    public init() {}
    
    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let didTapAddMemberButton: PublishRelay<Void>
    }
    
    struct Output {
        
    }
    
    func transform(_ input: Input) -> Output {
        
        input.rxViewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                
            })
            .disposed(by: disposeBag)
        
        input.didTapAddMemberButton
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.moveToAddMemeber()
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
}
