//
//  SignUpDIContainer.swift
//  SignUpFeature
//
//  Created by 선민재 on 3/4/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import SignUpPresentation
import SignUpData
import SignUpDomain
import BaseData

public final class SignUpDIContainer {

    private func makeSignUpProvider() -> DefaultProvider<SignUpTargetType> {
        return DefaultProvider<SignUpTargetType>()
    }

    private func makeSignUpRepository() -> SignUpRepository {
        return DefaultSignUpRepository(provider: makeSignUpProvider())
    }

    private func makeSignUpUseCase() -> SignUpUseCase {
        return DefaultSignUpUseCase(signUpRepository: makeSignUpRepository())
    }

    func makeSignUpViewModel() -> SignUpViewModel {
        return SignUpViewModel(signUpUseCase: makeSignUpUseCase())
    }

    func makeSignUpViewController(with viewModel: SignUpViewModel) -> SignUpViewController {
        return SignUpViewController(with: viewModel)
    }
}
