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

import BaseDomain
import HomeDomain

public final class HomeViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    public struct Action {
        public let moveToTicket: (_ capsuleId: Int) -> Void

        public init(moveToTicket: @escaping (_ capsuleId: Int) -> Void) {
            self.moveToTicket = moveToTicket
        }
    }

    public let action: Action

    private let homeUseCase: HomeUseCase
    private let role: TimeCapsuleRole

    private let ticketList: BehaviorRelay<[TimeCapsuleEntity]> = .init(value: [])

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let didTapTicketList: ControlEvent<IndexPath>
    }

    struct Output {
        let ticketList: BehaviorRelay<[TimeCapsuleEntity]>
    }

    func transform(_ input: Input) -> Output {

        input.rxViewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                Task {
                    do {
                        let capsules = try await self.homeUseCase.fetchMyTimeCapsules(role: self.role)
                        await MainActor.run {
                            self.ticketList.accept(capsules)
                        }
                    } catch {
                        await MainActor.run {
                            self.ticketList.accept([])
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        input.didTapTicketList
            .withUnretained(self)
            .subscribe(onNext: { (self, indexPath) in
                guard indexPath.item < self.ticketList.value.count else { return }
                let capsuleId = self.ticketList.value[indexPath.item].timeCapsuleId
                self.action.moveToTicket(capsuleId)
            })
            .disposed(by: disposeBag)

        return Output(ticketList: ticketList)
    }

    public init(
        action: Action,
        homeUseCase: HomeUseCase,
        role: TimeCapsuleRole
    ) {
        self.action = action
        self.homeUseCase = homeUseCase
        self.role = role
    }
}
