//
//  EnterTicketViewModel.swift
//  HomePresentation
//
//  Created by 선민재 on 12/23/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

import BaseDomain

public final class EnterTicketViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let timeCapsuleUseCase: TimeCapsuleUseCase

    struct Input {
        let didTapEnterButton: PublishRelay<String>
    }

    struct Output {
        let joinSuccess: PublishRelay<Void>
        let joinError: PublishRelay<String>
    }

    func transform(_ input: Input) -> Output {
        let joinSuccess: PublishRelay<Void> = .init()
        let joinError: PublishRelay<String> = .init()

        input.didTapEnterButton
            .withUnretained(self)
            .subscribe(onNext: { (self, code) in
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        try await self.timeCapsuleUseCase.joinRequest(code: code)
                        await MainActor.run {
                            joinSuccess.accept(())
                        }
                    } catch let error {
                        await MainActor.run {
                            joinError.accept(error.localizedDescription)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        return Output(
            joinSuccess: joinSuccess,
            joinError: joinError
        )
    }

    public init(timeCapsuleUseCase: TimeCapsuleUseCase) {
        self.timeCapsuleUseCase = timeCapsuleUseCase
    }
}
