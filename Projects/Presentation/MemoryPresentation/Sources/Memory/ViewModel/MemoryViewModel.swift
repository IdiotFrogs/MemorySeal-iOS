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
    func moveToManageTicket()
}

public final class MemoryViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    public var delegate: MemoryViewModelDelegate?

    private let capsuleId: Int

    public init(capsuleId: Int) {
        self.capsuleId = capsuleId
    }

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let didTapAddMemberButton: PublishRelay<Void>
        let didTapManageButton: PublishRelay<Void>
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

        input.didTapManageButton
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.moveToManageTicket()
            })
            .disposed(by: disposeBag)


        return Output()
    }
}
