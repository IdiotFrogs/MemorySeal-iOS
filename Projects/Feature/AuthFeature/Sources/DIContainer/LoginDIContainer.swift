//
//  LoginDIContainer.swift
//  LoginFeature
//
//  Created by 선민재 on 5/1/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation

import AuthPresentation
import AuthData
import AuthDomain

public final class LoginDIContainer {
    private func makeAuthRepository() -> AuthRepository {
        return DefaultAuthRepository()
    }
    
    private func makeAuthUseCase() -> AuthUseCase {
        return DefaultAuthUseCase(
            authRepository: makeAuthRepository()
        )
    }
    
    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(
            authUseCase: makeAuthUseCase()
        )
    }
    
    func makeLoginViewController(
        with viewModel: LoginViewModel
    ) -> LoginViewController {
        return LoginViewController(with: viewModel)
    }
}
