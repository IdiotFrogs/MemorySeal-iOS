//
//  ManageTicketViewModel.swift
//  TicketPresentation
//
//  Created by 선민재 on 4/7/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

import TicketDomain

public final class ManageTicketViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    public struct Action {
        public let didDeleteTimeCapsule: () -> Void
        public let didLeaveTimeCapsule: () -> Void
        public let moveToMemberList: () -> Void

        public init(
            didDeleteTimeCapsule: @escaping () -> Void,
            didLeaveTimeCapsule: @escaping () -> Void,
            moveToMemberList: @escaping () -> Void
        ) {
            self.didDeleteTimeCapsule = didDeleteTimeCapsule
            self.didLeaveTimeCapsule = didLeaveTimeCapsule
            self.moveToMemberList = moveToMemberList
        }
    }

    public let action: Action

    private let capsuleId: Int
    private let manageTicketUseCase: ManageTicketUseCase
    let ticketName: String
    let isHost: Bool

    public init(
        action: Action,
        capsuleId: Int,
        ticketName: String,
        isHost: Bool,
        manageTicketUseCase: ManageTicketUseCase
    ) {
        self.action = action
        self.capsuleId = capsuleId
        self.ticketName = ticketName
        self.isHost = isHost
        self.manageTicketUseCase = manageTicketUseCase
    }

    struct Input {
        let didConfirmDelete: PublishRelay<Void>
        let didConfirmLeave: PublishRelay<Void>
        let didTapMember: PublishRelay<Void>
    }

    struct Output {
        let errorToast: Signal<String>
        let hostCannotLeave: Signal<Void>
    }

    func transform(_ input: Input) -> Output {
        let errorToast = PublishRelay<String>()
        let hostCannotLeave = PublishRelay<Void>()

        input.didTapMember
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToMemberList()
            })
            .disposed(by: disposeBag)

        input.didConfirmDelete
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                Task {
                    do {
                        try await self.manageTicketUseCase.deleteTimeCapsule(capsuleId: self.capsuleId)
                        await MainActor.run {
                            self.action.didDeleteTimeCapsule()
                        }
                    } catch {
                        await MainActor.run {
                            errorToast.accept("티켓 삭제에 실패했습니다. 다시 시도해주세요.")
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
                            self.action.didLeaveTimeCapsule()
                        }
                    } catch ManageTicketError.hostCannotLeave {
                        await MainActor.run {
                            hostCannotLeave.accept(())
                        }
                    } catch {
                        await MainActor.run {
                            errorToast.accept("티켓 나가기에 실패했습니다. 다시 시도해주세요.")
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        return Output(
            errorToast: errorToast.asSignal(),
            hostCannotLeave: hostCannotLeave.asSignal()
        )
    }
}
