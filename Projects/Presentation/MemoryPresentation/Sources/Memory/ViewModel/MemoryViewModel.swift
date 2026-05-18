//
//  MemoryViewModel.swift
//  MemoryPresentation
//
//  Created by 선민재 on 7/28/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

import BaseDomain

public final class MemoryViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    public struct Action {
        public let moveToAddMember: () -> Void
        public let moveToManageTicket: () -> Void

        public init(moveToAddMember: @escaping () -> Void, moveToManageTicket: @escaping () -> Void) {
            self.moveToAddMember = moveToAddMember
            self.moveToManageTicket = moveToManageTicket
        }
    }

    public let action: Action

    private let capsuleId: Int
    private let timeCapsuleUseCase: TimeCapsuleUseCase

    public init(
        action: Action,
        capsuleId: Int,
        timeCapsuleUseCase: TimeCapsuleUseCase
    ) {
        self.action = action
        self.capsuleId = capsuleId
        self.timeCapsuleUseCase = timeCapsuleUseCase
    }

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let didTapAddMemberButton: PublishRelay<Void>
        let didTapManageButton: PublishRelay<Void>
    }

    struct Output {
        let detail: BehaviorRelay<TimeCapsuleDetailEntity?>
        let collaborators: BehaviorRelay<[CollaboratorEntity]>
    }

    func transform(_ input: Input) -> Output {
        let detail = BehaviorRelay<TimeCapsuleDetailEntity?>(value: nil)
        let collaborators = BehaviorRelay<[CollaboratorEntity]>(value: [])

        input.rxViewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.requestMemoryData(
                    detail: detail,
                    collaborators: collaborators
                )
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

        return Output(detail: detail, collaborators: collaborators)
    }
}

extension MemoryViewModel {
    private func requestMemoryData(
        detail: BehaviorRelay<TimeCapsuleDetailEntity?>,
        collaborators: BehaviorRelay<[CollaboratorEntity]>
    ) {
        Task { [weak self] in
            guard let self else { return }
            async let detailFetch = try? self.timeCapsuleUseCase.fetchTimeCapsuleDetail(capsuleId: self.capsuleId)
            async let collaboratorsFetch = try? self.timeCapsuleUseCase.fetchCollaborators(capsuleId: self.capsuleId)

            let fetchedDetail = await detailFetch
            let fetchedCollaborators = await collaboratorsFetch

            await MainActor.run {
                if let fetchedDetail {
                    detail.accept(fetchedDetail)
                }
                if let fetchedCollaborators {
                    collaborators.accept(fetchedCollaborators)
                }
            }
        }
    }
}
