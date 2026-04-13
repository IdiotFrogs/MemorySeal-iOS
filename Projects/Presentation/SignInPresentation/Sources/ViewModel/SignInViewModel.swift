//
//  SignInViewModel.swift
//  LoginPresentation
//
//  Created by 선민재 on 5/13/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

import SignInDomain

public protocol SignInViewModelDelegate: AnyObject {
    func moveToHome()
    func moveToSignUp()
}

public final class SignInViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let authUseCase: AuthUseCase
    
    public var delegate: SignInViewModelDelegate?
    
    public init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }
    
    struct Input {
        let appleAuthorizationCompleted: PublishRelay<(idToken: String, authorizationCode: String)>
        let googleAuthorizationCompleted: PublishRelay<String>
    }
    
    struct Output {
        
    }
    
    func translation(_ input: Input) -> Output {
        
        input.appleAuthorizationCompleted
            .withUnretained(self)
            .subscribe(onNext: { (self, element) in
                self.requestSignIn(
                    idToken: element.idToken,
                    authorizationCode: element.authorizationCode,
                    type: .apple
                )
            })
            .disposed(by: disposeBag)
        
        input.googleAuthorizationCompleted
            .subscribe(with: self, onNext: { (self, idToken) in
                self.requestSignIn(
                    idToken: idToken,
                    authorizationCode: nil,
                    type: .google
                )
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
}

extension SignInViewModel {
    private func requestSignIn(idToken: String, authorizationCode: String?, type: SignInType) {
        Task {
            let isOnboardingFinished: Bool = try await authUseCase.executeSignIn(
                idToken: idToken,
                authorizationCode: authorizationCode,
                type: type
            )

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
