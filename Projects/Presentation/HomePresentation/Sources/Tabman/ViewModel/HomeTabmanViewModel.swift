//
//  HomeTabmanViewModel.swift
//  HomePresentation
//
//  Created by 선민재 on 5/30/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

import BaseDomain

public final class HomeTabmanViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let userUseCase: UserUseCase

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

    private let profileImageUrl: PublishRelay<String?> = .init()
    private let refreshRelay: PublishRelay<Void> = .init()

    public func refresh() {
        refreshRelay.accept(())
    }

    public init(action: Action, userUseCase: UserUseCase) {
        self.action = action
        self.userUseCase = userUseCase
    }

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let createTicketButtonDidTap: ControlEvent<Void>
        let profileButtonDidTap: ControlEvent<Void>
        let enterTicketButtonDidTap: ControlEvent<Void>
    }

    struct Output {
        let profileImageUrl: Driver<String?>
    }

    func transform(_ input: Input) -> Output {
        Observable.merge(
            input.rxViewDidLoad.asObservable(),
            refreshRelay.asObservable()
        )
        .withUnretained(self)
        .subscribe(onNext: { (self, _) in
            Task {
                do {
                    let user = try await self.userUseCase.fetchUserInfo()
                    await MainActor.run {
                        self.profileImageUrl.accept(user.profileImageUrl)
                    }
                } catch {}
            }
        })
        .disposed(by: disposeBag)

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

        return Output(profileImageUrl: profileImageUrl.asDriver(onErrorJustReturn: nil))
    }
}
