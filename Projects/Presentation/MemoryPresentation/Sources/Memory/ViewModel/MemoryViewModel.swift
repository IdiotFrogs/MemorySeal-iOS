//
//  MemoryViewModel.swift
//  MemoryPresentation
//
//  Created by 선민재 on 7/28/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

public final class MemoryViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    public struct Action {
        public let moveToAddMember: () -> Void
        public let moveToManageTicket: () -> Void
        public let moveToMyMemoryMessages: () -> Void
        public let moveToBuryTicket: () -> Void

        public init(
            moveToAddMember: @escaping () -> Void,
            moveToManageTicket: @escaping () -> Void,
            moveToMyMemoryMessages: @escaping () -> Void,
            moveToBuryTicket: @escaping () -> Void
        ) {
            self.moveToAddMember = moveToAddMember
            self.moveToManageTicket = moveToManageTicket
            self.moveToMyMemoryMessages = moveToMyMemoryMessages
            self.moveToBuryTicket = moveToBuryTicket
        }
    }

    public let action: Action

    private let capsuleId: Int

    public init(action: Action, capsuleId: Int) {
        self.action = action
        self.capsuleId = capsuleId
    }

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let didTapAddMemberButton: PublishRelay<Void>
        let didTapManageButton: PublishRelay<Void>
        let didTapSeeMessagesButton: PublishRelay<Void>
        let didTapBuryTicketButton: PublishRelay<Void>
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
                self.action.moveToAddMember()
            })
            .disposed(by: disposeBag)

        input.didTapManageButton
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToManageTicket()
            })
            .disposed(by: disposeBag)

        input.didTapSeeMessagesButton
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToMyMemoryMessages()
            })
            .disposed(by: disposeBag)

        input.didTapBuryTicketButton
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToBuryTicket()
            })
            .disposed(by: disposeBag)

        return Output()
    }
}
