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
        public let moveToManageTicket: (_ ticketName: String, _ isHost: Bool) -> Void
        public let moveToMyTicketMessages: () -> Void
        public let moveToBuryTicket: () -> Void
        public let moveToWatering: () -> Void
        public let moveToMemoryMessages: () -> Void

        public init(
            moveToAddMember: @escaping () -> Void,
            moveToManageTicket: @escaping (_ ticketName: String, _ isHost: Bool) -> Void,
            moveToMyTicketMessages: @escaping () -> Void,
            moveToBuryTicket: @escaping () -> Void,
            moveToWatering: @escaping () -> Void,
            moveToMemoryMessages: @escaping () -> Void
        ) {
            self.moveToAddMember = moveToAddMember
            self.moveToManageTicket = moveToManageTicket
            self.moveToMyTicketMessages = moveToMyTicketMessages
            self.moveToBuryTicket = moveToBuryTicket
            self.moveToWatering = moveToWatering
            self.moveToMemoryMessages = moveToMemoryMessages
        }
    }

    public let action: Action

    private let capsuleId: Int
    private let ticketDetailUseCase: TicketDetailUseCase
    private let addMemberUseCase: AddMemberUseCase

    private let ticketDetail: BehaviorRelay<TicketDetailEntity?> = .init(value: nil)
    private let collaborators: BehaviorRelay<[CollaboratorEntity]> = .init(value: [])
    private let memberCount: BehaviorRelay<Int> = .init(value: 0)
    private let errorToast: PublishRelay<String> = .init()
    private let refreshRelay: PublishRelay<Void> = .init()

    public func refresh() {
        refreshRelay.accept(())
    }

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
        let didTapWaterButton: PublishRelay<Void>
        let didTapSeeMemoriesButton: PublishRelay<Void>
    }

    struct Output {
        let ticketDetail: Driver<TicketDetailEntity?>
        let collaborators: Driver<[CollaboratorEntity]>
        let memberCount: Driver<Int>
        let errorToast: Signal<String>
        let viewState: Driver<TicketDetailViewState>
    }

    private static func makeViewState(from detail: TicketDetailEntity?) -> TicketDetailViewState {
        guard let detail else { return .initial }

        if detail.timeCapsuleStatus == .opened {
            return TicketDetailViewState(
                sections: [.ticketImage, .ticketDescription, .members],
                isOpened: true
            )
        }

        var sections: [TicketDetailSection] = [.ticketImage, .ticketDescription]
        if detail.userRole == .host || detail.timeCapsuleStatus == .buried {
            sections.append(.buryTicket)
        }
        sections.append(contentsOf: [.myMessages, .members])

        return TicketDetailViewState(sections: sections, isOpened: false)
    }

    func transform(_ input: Input) -> Output {

        Observable.merge(
            input.rxViewDidLoad.asObservable(),
            refreshRelay.asObservable()
        )
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
            .withLatestFrom(ticketDetail.asObservable())
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { (self, detail) in
                self.action.moveToManageTicket(detail.title, detail.userRole == .host)
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

        input.didTapWaterButton
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToWatering()
            })
            .disposed(by: disposeBag)

        input.didTapSeeMemoriesButton
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToMemoryMessages()
            })
            .disposed(by: disposeBag)

        return Output(
            ticketDetail: ticketDetail.asDriver(),
            collaborators: collaborators.asDriver(),
            memberCount: memberCount.asDriver(),
            errorToast: errorToast.asSignal(),
            viewState: ticketDetail
                .map(Self.makeViewState(from:))
                .asDriver(onErrorJustReturn: .initial)
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
                let page = try await self.addMemberUseCase.fetchCollaborators(capsuleId: self.capsuleId, page: 0, size: 12)
                await MainActor.run {
                    self.collaborators.accept(page.collaborators)
                    self.memberCount.accept(page.totalElements)
                }
            } catch {
                await MainActor.run {
                    self.errorToast.accept("멤버 목록을 불러올 수 없습니다")
                }
            }
        }
    }
}
