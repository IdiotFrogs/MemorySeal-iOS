//
//  ManageTicketViewModel.swift
//  MemoryPresentation
//
//  Created by 선민재 on 4/7/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

import BaseDomain
import MemoryDomain

public final class ManageTicketViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    public struct Action {
        public let didDeleteTimeCapsule: () -> Void
        public let didLeaveTimeCapsule: () -> Void

        public init(
            didDeleteTimeCapsule: @escaping () -> Void,
            didLeaveTimeCapsule: @escaping () -> Void
        ) {
            self.didDeleteTimeCapsule = didDeleteTimeCapsule
            self.didLeaveTimeCapsule = didLeaveTimeCapsule
        }
    }

    public let action: Action

    private let capsuleId: Int
    private let timeCapsuleUseCase: TimeCapsuleUseCase
    private let manageTicketUseCase: ManageTicketUseCase
    let ticketName: String

    public init(
        action: Action,
        capsuleId: Int,
        ticketName: String,
        timeCapsuleUseCase: TimeCapsuleUseCase,
        manageTicketUseCase: ManageTicketUseCase
    ) {
        self.action = action
        self.capsuleId = capsuleId
        self.ticketName = ticketName
        self.timeCapsuleUseCase = timeCapsuleUseCase
        self.manageTicketUseCase = manageTicketUseCase
    }

    struct Input {
        let didConfirmDelete: PublishRelay<Void>
        let didConfirmLeave: PublishRelay<Void>
    }

    struct Output {
        let deleteResult: Driver<Bool>
        let leaveResult: Driver<Bool>
    }

    func transform(_ input: Input) -> Output {
        let deleteResult = PublishRelay<Bool>()
        let leaveResult = PublishRelay<Bool>()

        input.didConfirmDelete
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                Task {
                    do {
                        try await self.timeCapsuleUseCase.deleteTimeCapsule(capsuleId: self.capsuleId)
                        await MainActor.run {
                            deleteResult.accept(true)
                            self.action.didDeleteTimeCapsule()
                        }
                    } catch {
                        await MainActor.run {
                            deleteResult.accept(false)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        input.didConfirmLeave
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                Task {
                    do {
                        try await self.manageTicketUseCase.leaveTimeCapsule(capsuleId: self.capsuleId)
                        await MainActor.run {
                            leaveResult.accept(true)
                            self.action.didLeaveTimeCapsule()
                        }
                    } catch {
                        await MainActor.run {
                            leaveResult.accept(false)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        return Output(
            deleteResult: deleteResult.asDriver(onErrorJustReturn: false),
            leaveResult: leaveResult.asDriver(onErrorJustReturn: false)
        )
    }
}
