//
//  SplashViewModel.swift
//  SplashPresentation
//
//  Created by 선민재 on 3/19/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import SignInDomain

public final class SplashViewModel {
    public struct Action {
        public let moveToSignIn: () -> Void
        public let moveToHome: () -> Void
        public let moveToSignUp: () -> Void

        public init(moveToSignIn: @escaping () -> Void, moveToHome: @escaping () -> Void, moveToSignUp: @escaping () -> Void) {
            self.moveToSignIn = moveToSignIn
            self.moveToHome = moveToHome
            self.moveToSignUp = moveToSignUp
        }
    }

    private let authUseCase: AuthUseCase
    public let action: Action

    public init(authUseCase: AuthUseCase, action: Action) {
        self.authUseCase = authUseCase
        self.action = action
    }

    public func executeAutoSignIn() {
        Task {
            do {
                let isOnboarding = try await authUseCase.executeAutoSignIn()
                await MainActor.run {
                    if isOnboarding {
                        action.moveToHome()
                    } else {
                        action.moveToSignUp()
                    }
                }
            } catch {
                await MainActor.run {
                    action.moveToSignIn()
                }
            }
        }
    }
}
