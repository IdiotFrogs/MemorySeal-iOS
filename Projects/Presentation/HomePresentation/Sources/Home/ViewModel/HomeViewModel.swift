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

public final class HomeViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    public struct Action {
        public let moveToMemory: (_ capsuleId: Int) -> Void

        public init(moveToMemory: @escaping (_ capsuleId: Int) -> Void) {
            self.moveToMemory = moveToMemory
        }
    }

    public let action: Action

    private let timeCapsuleUseCase: TimeCapsuleUseCase
    private let role: TimeCapsuleRole

    private let memoryList: BehaviorRelay<[TimeCapsuleEntity]> = .init(value: [])

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let didTapMemoryList: ControlEvent<IndexPath>
    }

    struct Output {
        let memoryList: BehaviorRelay<[TimeCapsuleEntity]>
    }

    func transform(_ input: Input) -> Output {

        input.rxViewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                Task {
                    do {
                        let capsules = try await self.timeCapsuleUseCase.fetchMyTimeCapsules(role: self.role)
                        await MainActor.run {
                            self.memoryList.accept(capsules)
                        }
                    } catch {
                        await MainActor.run {
                            self.memoryList.accept([])
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        input.didTapMemoryList
            .withUnretained(self)
            .subscribe(onNext: { (self, indexPath) in
                guard indexPath.item < self.memoryList.value.count else { return }
                let capsuleId = self.memoryList.value[indexPath.item].timeCapsuleId
                self.action.moveToMemory(capsuleId)
            })
            .disposed(by: disposeBag)

        return Output(memoryList: memoryList)
    }

    public init(
        action: Action,
        timeCapsuleUseCase: TimeCapsuleUseCase,
        role: TimeCapsuleRole
    ) {
        self.action = action
        self.timeCapsuleUseCase = timeCapsuleUseCase
        self.role = role
    }
}
