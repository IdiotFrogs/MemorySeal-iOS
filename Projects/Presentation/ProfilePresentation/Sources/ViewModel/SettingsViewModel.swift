//
//  SettingsViewModel.swift
//  ProfilePresentation
//
//  Created by 선민재 on 3/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

import SignInDomain
import BaseDomain

public final class SettingsViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let authUseCase: AuthUseCase
    private let userUseCase: UserUseCase

    public struct Action {
        public let moveToBack: () -> Void
        public let moveToTermsOfService: () -> Void
        public let moveToLogout: () -> Void
        public let moveToWithdrawal: () -> Void

        public init(moveToBack: @escaping () -> Void, moveToTermsOfService: @escaping () -> Void, moveToLogout: @escaping () -> Void, moveToWithdrawal: @escaping () -> Void) {
            self.moveToBack = moveToBack
            self.moveToTermsOfService = moveToTermsOfService
            self.moveToLogout = moveToLogout
            self.moveToWithdrawal = moveToWithdrawal
        }
    }
    public let action: Action

    public init(authUseCase: AuthUseCase, userUseCase: UserUseCase, action: Action) {
        self.authUseCase = authUseCase
        self.userUseCase = userUseCase
        self.action = action
    }

    struct Input {
        let backButtonDidTap: ControlEvent<Void>
        let termsOfServiceDidTap: ControlEvent<Void>
        let logoutButtonDidTap: Observable<Void>
        let withdrawalDidTap: Observable<Void>
    }

    struct Output {}

    func translation(_ input: Input) -> Output {
        input.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToBack()
            })
            .disposed(by: disposeBag)

        input.termsOfServiceDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToTermsOfService()
            })
            .disposed(by: disposeBag)

        input.logoutButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.requestSignOut()
            })
            .disposed(by: disposeBag)

        input.withdrawalDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.requestDeleteAccount()
            })
            .disposed(by: disposeBag)

        return Output()
    }
}

extension SettingsViewModel {
    private func requestSignOut() {
        Task { [weak self] in
            guard let self else { return }
            try? await self.authUseCase.executeLogout()
            await MainActor.run { [weak self] in
                self?.action.moveToLogout()
            }
        }
    }

    private func requestDeleteAccount() {
        Task { [weak self] in
            guard let self else { return }
            try? await self.userUseCase.deleteAccount()
            await MainActor.run { [weak self] in
                self?.action.moveToWithdrawal()
            }
        }
    }
}
