//
//  AddMemberViewModel.swift
//  MemoryPresentation
//
//  Created by 선민재 on 11/17/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

import MemoryDomain

public final class AddMemberViewModel {
    private let disposeBag = DisposeBag()

    private let capsuleId: Int
    private let addMemberUseCase: AddMemberUseCase

    public init(
        capsuleId: Int,
        addMemberUseCase: AddMemberUseCase
    ) {
        self.capsuleId = capsuleId
        self.addMemberUseCase = addMemberUseCase
    }

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let didTapCopyInviteCode: PublishRelay<Void>
        let didConfirmDelegateHost: PublishRelay<Int>
    }

    struct Output {
        let memberList: PublishRelay<[CollaboratorEntity]>
        let inviteCode: PublishRelay<String>
        let errorToast: PublishRelay<String>
        let delegateHostSuccess: PublishRelay<Void>
    }

    func transform(_ input: Input) -> Output {
        let memberList: PublishRelay<[CollaboratorEntity]> = .init()
        let inviteCode: PublishRelay<String> = .init()
        let errorToast: PublishRelay<String> = .init()
        let delegateHostSuccess: PublishRelay<Void> = .init()

        input.rxViewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        let collaborators = try await self.addMemberUseCase.fetchCollaborators(
                            capsuleId: self.capsuleId
                        )
                        await MainActor.run {
                            memberList.accept(collaborators)
                        }
                    } catch {
                        await MainActor.run {
                            errorToast.accept("멤버 목록을 불러올 수 없습니다")
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
                        let updated = try await self.addMemberUseCase.fetchCollaborators(
                            capsuleId: self.capsuleId
                        )
                        await MainActor.run {
                            delegateHostSuccess.accept(())
                            memberList.accept(updated)
                        }
                    } catch {
                        await MainActor.run {
                            errorToast.accept("방장 위임에 실패했습니다")
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        return .init(
            memberList: memberList,
            inviteCode: inviteCode,
            errorToast: errorToast,
            delegateHostSuccess: delegateHostSuccess
        )
    }
}
