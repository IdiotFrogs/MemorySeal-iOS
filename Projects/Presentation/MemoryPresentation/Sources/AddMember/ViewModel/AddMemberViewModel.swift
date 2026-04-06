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

import BaseDomain

public final class AddMemberViewModel {
    private let disposeBag = DisposeBag()

    private let capsuleId: Int
    private let timeCapsuleUseCase: TimeCapsuleUseCase

    public init(
        capsuleId: Int,
        timeCapsuleUseCase: TimeCapsuleUseCase
    ) {
        self.capsuleId = capsuleId
        self.timeCapsuleUseCase = timeCapsuleUseCase
    }

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let didTapCopyInviteCode: PublishRelay<Void>
    }

    struct Output {
        let memberList: PublishRelay<[String]>
        let inviteCode: PublishRelay<String>
        let errorToast: PublishRelay<String>
    }

    func transform(_ input: Input) -> Output {
        let memberList: PublishRelay<[String]> = .init()
        let inviteCode: PublishRelay<String> = .init()
        let errorToast: PublishRelay<String> = .init()

        input.rxViewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                memberList.accept([
                    "유저 1",
                    "유저 2",
                    "유저 3",
                    "유저 4",
                    "유저 5",
                    "유저 6",
                    "유저 7",
                    "유저 8"
                ])
            })
            .disposed(by: disposeBag)

        input.didTapCopyInviteCode
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        let code = try await self.timeCapsuleUseCase.inviteToTimeCapsule(
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

        return .init(
            memberList: memberList,
            inviteCode: inviteCode,
            errorToast: errorToast
        )
    }
}
