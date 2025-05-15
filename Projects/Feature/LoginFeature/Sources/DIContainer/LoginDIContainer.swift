//
//  LoginDIContainer.swift
//  LoginFeature
//
//  Created by 선민재 on 5/1/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation

import LoginPresentation

public final class LoginDIContainer {
    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel()
    }
    
    func makeLoginViewController(
        with viewModel: LoginViewModel
    ) -> LoginViewController {
        return LoginViewController(with: viewModel)
    }
}
