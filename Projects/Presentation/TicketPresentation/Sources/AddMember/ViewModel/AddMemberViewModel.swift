//
//  AddMemberViewModel.swift
//  TicketPresentation
//
//  Created by 선민재 on 11/17/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

import BaseDomain
import TicketDomain

public final class AddMemberViewModel {
    private let disposeBag = DisposeBag()

    private let capsuleId: Int
    private let addMemberUseCase: AddMemberUseCase
    private var cachedMemberList: [CollaboratorEntity] = []

    private let pageSize: Int = 20
    private var currentPage: Int = 0
    private var isLast: Bool = false
    private var isLoading: Bool = false
    private var isSearching: Bool = false

    public init(
        capsuleId: Int,
        addMemberUseCase: AddMemberUseCase
    ) {
        self.capsuleId = capsuleId
        self.addMemberUseCase = addMemberUseCase
    }

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let searchText: Observable<String>
        let prefetchRows: Observable<[IndexPath]>
        let didTapCopyInviteCode: PublishRelay<Void>
        let didConfirmDelegateHost: PublishRelay<Int>
        let didConfirmKickContributor: PublishRelay<Int>
    }

    struct Output {
        let memberList: PublishRelay<[CollaboratorEntity]>
        let isCurrentUserHost: BehaviorRelay<Bool>
        let inviteCode: PublishRelay<String>
        let errorToast: PublishRelay<String>
        let delegateHostSuccess: PublishRelay<Void>
        let kickContributorSuccess: PublishRelay<Void>
    }

    func transform(_ input: Input) -> Output {
        let memberList: PublishRelay<[CollaboratorEntity]> = .init()
        let isCurrentUserHost: BehaviorRelay<Bool> = .init(value: false)
        let inviteCode: PublishRelay<String> = .init()
        let errorToast: PublishRelay<String> = .init()
        let delegateHostSuccess: PublishRelay<Void> = .init()
        let kickContributorSuccess: PublishRelay<Void> = .init()

        let loadMembers: (Bool) -> Void = { [weak self] reset in
            guard let self else { return }
            guard !self.isLoading else { return }
            if reset {
                self.currentPage = 0
                self.isLast = false
            }
            guard !self.isLast else { return }
            self.isLoading = true
            Task { [weak self] in
                guard let self else { return }
                do {
                    let page = try await self.addMemberUseCase.fetchCollaborators(
                        capsuleId: self.capsuleId,
                        page: self.currentPage,
                        size: self.pageSize
                    )
                    await MainActor.run {
                        if reset {
                            self.cachedMemberList = page.collaborators
                        } else {
                            self.cachedMemberList.append(contentsOf: page.collaborators)
                        }
                        self.isLast = page.isLast
                        self.currentPage += 1
                        self.isLoading = false
                        isCurrentUserHost.accept(self.cachedMemberList.first(where: { $0.isMe })?.role == .host)
                        memberList.accept(self.cachedMemberList)
                    }
                } catch {
                    await MainActor.run {
                        self.isLoading = false
                        errorToast.accept("멤버 목록을 불러올 수 없습니다")
                    }
                }
            }
        }

        input.rxViewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (_, _) in
                loadMembers(true)
            })
            .disposed(by: disposeBag)

        input.prefetchRows
            .withUnretained(self)
            .subscribe(onNext: { (self, indexPaths) in
                guard !self.isSearching, !self.isLoading, !self.isLast else { return }
                let threshold = self.cachedMemberList.count - 2
                if indexPaths.contains(where: { $0.item >= threshold }) {
                    loadMembers(false)
                }
            })
            .disposed(by: disposeBag)

        input.searchText
            .skip(1)
            .distinctUntilChanged()
            .debounce(.milliseconds(600), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, text) in
                let keyword = text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !keyword.isEmpty else {
                    self.isSearching = false
                    memberList.accept(self.cachedMemberList)
                    return
                }
                self.isSearching = true
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        let results = try await self.addMemberUseCase.searchCollaborators(
                            capsuleId: self.capsuleId,
                            nickname: keyword
                        )
                        await MainActor.run {
                            memberList.accept(results)
                        }
                    } catch {
                        await MainActor.run {
                            errorToast.accept("멤버 검색에 실패했습니다")
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        input.didTapCopyInviteCode
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        let code = try await self.addMemberUseCase.inviteToTimeCapsule(
                            capsuleId: self.capsuleId
                        )
                        await MainActor.run {
                            inviteCode.accept(code)
                        }
                    } catch {
                        await MainActor.run {
                            errorToast.accept("참여 코드를 가져올 수 없습니다")
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        input.didConfirmDelegateHost
            .withUnretained(self)
            .subscribe(onNext: { (self, targetUserId) in
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        try await self.addMemberUseCase.delegateHost(
                            capsuleId: self.capsuleId,
                            targetUserId: targetUserId
                        )
                        await MainActor.run {
                            delegateHostSuccess.accept(())
                            loadMembers(true)
                        }
                    } catch {
                        await MainActor.run {
                            errorToast.accept("방장 위임에 실패했습니다")
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        input.didConfirmKickContributor
            .withUnretained(self)
            .subscribe(onNext: { (self, targetUserId) in
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        try await self.addMemberUseCase.kickContributor(
                            capsuleId: self.capsuleId,
                            targetUserId: targetUserId
                        )
                        await MainActor.run {
                            kickContributorSuccess.accept(())
                            loadMembers(true)
                        }
                    } catch {
                        await MainActor.run {
                            errorToast.accept("멤버 추방에 실패했습니다")
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        return .init(
            memberList: memberList,
            isCurrentUserHost: isCurrentUserHost,
            inviteCode: inviteCode,
            errorToast: errorToast,
            delegateHostSuccess: delegateHostSuccess,
            kickContributorSuccess: kickContributorSuccess
        )
    }
}
