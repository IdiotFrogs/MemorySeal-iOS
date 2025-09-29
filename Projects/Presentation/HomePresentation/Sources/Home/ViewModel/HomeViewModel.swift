//
//  HomeViewModel.swift
//  HomePresentation
//
//  Created by 선민재 on 5/26/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public protocol HomeViewModelDelegate: AnyObject {
    func moveToMemory()
}

public final class HomeViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    public var delegate: HomeViewModelDelegate?
    
    private let memoryList: PublishRelay<[String]> = .init()
    
    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let didTapMemoryList: ControlEvent<IndexPath>
    }
    
    struct Output {
        let memoryList: PublishRelay<[String]>
    }
    
    func transform(_ input: Input) -> Output {
        
        input.rxViewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.memoryList.accept([
                    "dummy1",
                    "dummy2"
                ])
            })
            .disposed(by: disposeBag)
        
        input.didTapMemoryList
            .withUnretained(self)
            .subscribe(onNext: { (self, indexPath) in
                self.delegate?.moveToMemory()
            })
            .disposed(by: disposeBag)
        
        return Output(memoryList: memoryList)
    }
    public init() {}
}
