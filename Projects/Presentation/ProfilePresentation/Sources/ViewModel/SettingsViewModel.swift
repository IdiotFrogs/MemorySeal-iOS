//
//  SettingsViewModel.swift
//  ProfilePresentation
//
//  Created by 선민재 on 3/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

import AuthDomain
import BaseDomain

public protocol SettingsViewModelDelegate: AnyObject {
    func moveToBack()
    func moveToTermsOfService()
    func moveToLogout()
    func moveToWithdrawal()
}

public final class SettingsViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let authUseCase: AuthUseCase
    private let userUseCase: UserUseCase
    public weak var delegate: SettingsViewModelDelegate?

    public init(authUseCase: AuthUseCase, userUseCase: UserUseCase) {
        self.authUseCase = authUseCase
        self.userUseCase = userUseCase
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
                self.delegate?.moveToBack()
            })
            .disposed(by: disposeBag)

        input.termsOfServiceDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.moveToTermsOfService()
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
        Task {
            try? await self.authUseCase.executeLogout()
            await MainActor.run {
                self.delegate?.moveToLogout()
            }
        }
    }

    private func requestDeleteAccount() {
        Task {
            try? await self.userUseCase.deleteAccount()
            await MainActor.run {
                self.delegate?.moveToWithdrawal()
            }
        }
    }
}
