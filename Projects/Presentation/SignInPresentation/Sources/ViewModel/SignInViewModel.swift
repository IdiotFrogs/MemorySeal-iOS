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

public final class SignInViewModel {
    public struct Action {
        public let moveToHome: () -> Void
        public let moveToSignUp: () -> Void

        public init(moveToHome: @escaping () -> Void, moveToSignUp: @escaping () -> Void) {
            self.moveToHome = moveToHome
            self.moveToSignUp = moveToSignUp
        }
    }

    private let disposeBag: DisposeBag = DisposeBag()
    private let authUseCase: AuthUseCase
    public let action: Action

    public init(authUseCase: AuthUseCase, action: Action) {
        self.authUseCase = authUseCase
        self.action = action
    }
    
    struct Input {
        let appleAuthorizationCompleted: PublishRelay<(idToken: String, authorizationCode: String)>
        let googleAuthorizationCompleted: PublishRelay<String>
    }
    
    struct Output {
        let isLoading: BehaviorRelay<Bool>
    }

    func translation(_ input: Input) -> Output {
        let isLoading = BehaviorRelay<Bool>(value: false)

        input.appleAuthorizationCompleted
            .withUnretained(self)
            .subscribe(onNext: { (self, element) in
                self.requestSignIn(
                    idToken: element.idToken,
                    authorizationCode: element.authorizationCode,
                    type: .apple,
                    isLoading: isLoading
                )
            })
            .disposed(by: disposeBag)

        input.googleAuthorizationCompleted
            .subscribe(with: self, onNext: { (self, idToken) in
                self.requestSignIn(
                    idToken: idToken,
                    authorizationCode: nil,
                    type: .google,
                    isLoading: isLoading
                )
            })
            .disposed(by: disposeBag)

        return Output(isLoading: isLoading)
    }
}

extension SignInViewModel {
    private func requestSignIn(
        idToken: String,
        authorizationCode: String?,
        type: SignInType,
        isLoading: BehaviorRelay<Bool>
    ) {
        isLoading.accept(true)
        Task {
            let minimumDisplay = Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            do {
                let isOnboardingFinished: Bool = try await authUseCase.executeSignIn(
                    idToken: idToken,
                    authorizationCode: authorizationCode,
                    type: type
                )
                await minimumDisplay.value
                await MainActor.run {
                    isLoading.accept(false)
                    if isOnboardingFinished {
                        action.moveToHome()
                    } else {
                        action.moveToSignUp()
                    }
                }
            } catch {
                await minimumDisplay.value
                await MainActor.run {
                    isLoading.accept(false)
                }
            }
        }
    }
}
