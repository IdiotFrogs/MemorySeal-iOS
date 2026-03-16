//
//  SettingsViewModel.swift
//  ProfilePresentation
//
//  Created by 선민재 on 3/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

public protocol SettingsViewModelDelegate: AnyObject {
    func moveToBack()
    func moveToTermsOfService()
    func moveToLogout()
    func moveToWithdrawal()
}

public final class SettingsViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    public weak var delegate: SettingsViewModelDelegate?
    public init() {}

    struct Input {
        let backButtonDidTap: ControlEvent<Void>
        let termsOfServiceDidTap: ControlEvent<Void>
        let logoutDidTap: ControlEvent<Void>
        let withdrawalDidTap: ControlEvent<Void>
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

        input.logoutDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.moveToLogout()
            })
            .disposed(by: disposeBag)

        input.withdrawalDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.moveToWithdrawal()
            })
            .disposed(by: disposeBag)

        return Output()
    }
}
