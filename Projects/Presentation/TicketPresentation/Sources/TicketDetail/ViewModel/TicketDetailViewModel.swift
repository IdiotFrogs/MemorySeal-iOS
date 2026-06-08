//
//  TicketDetailViewModel.swift
//  TicketPresentation
//
//  Created by 선민재 on 7/28/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

import BaseDomain
import TicketDomain

public final class TicketDetailViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    public struct Action {
        public let moveToAddMember: () -> Void
        public let moveToManageTicket: () -> Void
        public let moveToMyTicketMessages: () -> Void
        public let moveToBuryTicket: () -> Void

        public init(
            moveToAddMember: @escaping () -> Void,
            moveToManageTicket: @escaping () -> Void,
            moveToMyTicketMessages: @escaping () -> Void,
            moveToBuryTicket: @escaping () -> Void
        ) {
            self.moveToAddMember = moveToAddMember
            self.moveToManageTicket = moveToManageTicket
            self.moveToMyTicketMessages = moveToMyTicketMessages
            self.moveToBuryTicket = moveToBuryTicket
        }
    }

    public let action: Action

    private let capsuleId: Int
    private let ticketDetailUseCase: TicketDetailUseCase
    private let addMemberUseCase: AddMemberUseCase

    private let ticketDetail: BehaviorRelay<TicketDetailEntity?> = .init(value: nil)
    private let collaborators: BehaviorRelay<[CollaboratorEntity]> = .init(value: [])
    private let errorToast: PublishRelay<String> = .init()

    public init(
        action: Action,
        capsuleId: Int,
        ticketDetailUseCase: TicketDetailUseCase,
        addMemberUseCase: AddMemberUseCase
    ) {
        self.action = action
        self.capsuleId = capsuleId
        self.ticketDetailUseCase = ticketDetailUseCase
        self.addMemberUseCase = addMemberUseCase
    }

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let didTapAddMemberButton: PublishRelay<Void>
        let didTapManageButton: PublishRelay<Void>
        let didTapSeeMessagesButton: PublishRelay<Void>
        let didTapBuryTicketButton: PublishRelay<Void>
    }

    struct Output {
        let ticketDetail: Driver<TicketDetailEntity?>
        let collaborators: Driver<[CollaboratorEntity]>
        let errorToast: Signal<String>
    }

    func transform(_ input: Input) -> Output {

        input.rxViewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.fetchTicketDetail()
                self.fetchCollaborators()
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
                self.action.moveToMyTicketMessages()
            })
            .disposed(by: disposeBag)

        input.didTapBuryTicketButton
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToBuryTicket()
            })
            .disposed(by: disposeBag)

        return Output(
            ticketDetail: ticketDetail.asDriver(),
            collaborators: collaborators.asDriver(),
            errorToast: errorToast.asSignal()
        )
    }
}

extension TicketDetailViewModel {
    private func fetchTicketDetail() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let detail = try await self.ticketDetailUseCase.fetchDetail(capsuleId: self.capsuleId)
                await MainActor.run {
                    self.ticketDetail.accept(detail)
                }
            } catch {
                await MainActor.run {
                    self.errorToast.accept("티켓 정보를 불러올 수 없습니다")
                }
            }
        }
    }

    private func fetchCollaborators() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let list = try await self.addMemberUseCase.fetchCollaborators(capsuleId: self.capsuleId)
                await MainActor.run {
                    self.collaborators.accept(list)
                }
            } catch {
                await MainActor.run {
                    self.errorToast.accept("멤버 목록을 불러올 수 없습니다")
                }
            }
        }
    }
}
