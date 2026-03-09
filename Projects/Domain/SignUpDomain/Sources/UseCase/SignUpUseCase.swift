//
//  SignUpUseCase.swift
//  AuthDomain
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import BaseDomain

public protocol SignUpUseCase {
    func execute(nickname: String, profileImage: Data) async throws
}

public final class DefaultSignUpUseCase: SignUpUseCase {

    private let signUpRepository: SignUpRepository

    public init(signUpRepository: SignUpRepository) {
        self.signUpRepository = signUpRepository
    }

    public func execute(nickname: String, profileImage: Data) async throws {
        try await signUpRepository.signUp(nickname: nickname, profileImage: profileImage)
    }
}
