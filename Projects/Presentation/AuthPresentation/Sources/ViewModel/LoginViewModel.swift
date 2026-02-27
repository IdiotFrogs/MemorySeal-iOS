//
//  LoginViewModel.swift
//  LoginPresentation
//
//  Created by 선민재 on 5/13/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

import AuthDomain

public protocol LoginViewModelDelegate: AnyObject {
    func moveToHome()
    func moveToSignUp()
}

public final class LoginViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let authUseCase: AuthUseCase
    
    public var delegate: LoginViewModelDelegate?
    
    public init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }
    
    struct Input {
        let appleLoginButtonDidTap: PublishRelay<Void>
        let oauthAuthorizationCompleted: PublishRelay<String>
    }
    
    struct Output {
        
    }
    
    func translation(_ input: Input) -> Output {
        
        input.appleLoginButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.moveToHome()
            })
            .disposed(by: disposeBag)
        
        input.oauthAuthorizationCompleted
            .subscribe(with: self, onNext: { (self, idToken) in
                self.requestSignIn(idToken)
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
}

extension LoginViewModel {
    private func requestSignIn(_ idToken: String) {
        Task {
            let isOnboardingFinished: Bool = try await authUseCase.executeSignIn(idToken)

            await MainActor.run {
                if isOnboardingFinished {
                    delegate?.moveToHome()
                } else {
                    delegate?.moveToSignUp()
                }
            }
        }
    }
}
