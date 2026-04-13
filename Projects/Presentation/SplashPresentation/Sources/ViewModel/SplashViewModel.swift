//
//  SplashViewModel.swift
//  SplashPresentation
//
//  Created by 선민재 on 3/19/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import SignInDomain

public protocol SplashViewModelDelegate: AnyObject {
    func moveToSignIn()
    func moveToHome()
    func moveToSignUp()
}

public final class SplashViewModel {
    private let authUseCase: AuthUseCase

    public weak var delegate: SplashViewModelDelegate?

    public init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }

    public func executeAutoSignIn() {
        Task {
            do {
                let isOnboarding = try await authUseCase.executeAutoSignIn()
                await MainActor.run {
                    if isOnboarding {
                        delegate?.moveToHome()
                    } else {
                        delegate?.moveToSignUp()
                    }
                }
            } catch {
                await MainActor.run {
                    delegate?.moveToSignIn()
                }
            }
        }
    }
}
