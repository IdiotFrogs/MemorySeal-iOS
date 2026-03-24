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

public protocol HomeViewModelDelegate: AnyObject {
    func moveToMemory()
}

public final class HomeViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    public var delegate: HomeViewModelDelegate?

    private let timeCapsuleUseCase: TimeCapsuleUseCase
    private let role: TimeCapsuleRole

    private let memoryList: PublishRelay<[TimeCapsuleEntity]> = .init()

    struct Input {
        let rxViewDidLoad: PublishRelay<Void>
        let didTapMemoryList: ControlEvent<IndexPath>
    }

    struct Output {
        let memoryList: PublishRelay<[TimeCapsuleEntity]>
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
                self.delegate?.moveToMemory()
            })
            .disposed(by: disposeBag)

        return Output(memoryList: memoryList)
    }

    public init(
        timeCapsuleUseCase: TimeCapsuleUseCase,
        role: TimeCapsuleRole
    ) {
        self.timeCapsuleUseCase = timeCapsuleUseCase
        self.role = role
    }
}
