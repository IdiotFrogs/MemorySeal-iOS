//
//  HomeTabmanViewModel.swift
//  HomePresentation
//
//  Created by 선민재 on 5/30/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

public final class HomeTabmanViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    public struct Action {
        public let moveToCreateTicket: () -> Void
        public let moveToProfile: () -> Void
        public let moveToEnterTicket: () -> Void

        public init(moveToCreateTicket: @escaping () -> Void, moveToProfile: @escaping () -> Void, moveToEnterTicket: @escaping () -> Void) {
            self.moveToCreateTicket = moveToCreateTicket
            self.moveToProfile = moveToProfile
            self.moveToEnterTicket = moveToEnterTicket
        }
    }

    public let action: Action

    public init(action: Action) {
        self.action = action
    }

    struct Input {
        let createTicketButtonDidTap: ControlEvent<Void>
        let profileButtonDidTap: ControlEvent<Void>
        let enterTicketButtonDidTap: ControlEvent<Void>
    }

    struct Output {

    }

    func transform(_ input: Input) -> Output {
        input.createTicketButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToCreateTicket()
            })
            .disposed(by: disposeBag)

        input.profileButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToProfile()
            })
            .disposed(by: disposeBag)

        input.enterTicketButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToEnterTicket()
            })
            .disposed(by: disposeBag)
        return Output()
    }
}
