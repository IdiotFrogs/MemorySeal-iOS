//
//  CreateTicketViewModel.swift
//  HomePresentation
//
//  Created by 선민재 on 5/30/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

public final class CreateTicketViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
        
    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
    }
    
    struct Output {
        
    }
    
    func transform(_ input: Input) -> Output {
        return Output()
    }
    public init() {}
}
