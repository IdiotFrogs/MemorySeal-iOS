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

public final class ManageTicketViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    public struct Action {
        public let didDeleteTimeCapsule: () -> Void

        public init(didDeleteTimeCapsule: @escaping () -> Void) {
            self.didDeleteTimeCapsule = didDeleteTimeCapsule
        }
    }

    public let action: Action

    private let capsuleId: Int
    private let timeCapsuleUseCase: TimeCapsuleUseCase
    let ticketName: String

    public init(
        action: Action,
        capsuleId: Int,
        ticketName: String,
        timeCapsuleUseCase: TimeCapsuleUseCase
    ) {
        self.action = action
        self.capsuleId = capsuleId
        self.ticketName = ticketName
        self.timeCapsuleUseCase = timeCapsuleUseCase
    }

    struct Input {
        let didConfirmDelete: PublishRelay<Void>
    }

    struct Output {
        let deleteResult: Driver<Bool>
    }

    func transform(_ input: Input) -> Output {
        let deleteResult = PublishRelay<Bool>()

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

        return Output(
            deleteResult: deleteResult.asDriver(onErrorJustReturn: false)
        )
    }
}
