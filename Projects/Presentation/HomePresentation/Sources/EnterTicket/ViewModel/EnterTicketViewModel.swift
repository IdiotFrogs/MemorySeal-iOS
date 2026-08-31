//
//  EnterTicketViewModel.swift
//  HomePresentation
//
//  Created by 선민재 on 12/23/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

import HomeDomain

public final class EnterTicketViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    public struct Action {
        public let didJoinTicket: (_ capsuleId: Int?) -> Void

        public init(didJoinTicket: @escaping (_ capsuleId: Int?) -> Void) {
            self.didJoinTicket = didJoinTicket
        }
    }

    public let action: Action

    private let enterTicketUseCase: EnterTicketUseCase

    struct Input {
        let didTapEnterButton: PublishRelay<String>
    }

    struct Output {
        let joinError: PublishRelay<String>
    }

    func transform(_ input: Input) -> Output {
        let joinError: PublishRelay<String> = .init()

        input.didTapEnterButton
            .withUnretained(self)
            .subscribe(onNext: { (self, code) in
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        let capsuleId = try await self.enterTicketUseCase.joinRequest(code: code)
                        await MainActor.run {
                            self.action.didJoinTicket(capsuleId)
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
            joinError: joinError
        )
    }

    public init(action: Action, enterTicketUseCase: EnterTicketUseCase) {
        self.action = action
        self.enterTicketUseCase = enterTicketUseCase
    }
}
