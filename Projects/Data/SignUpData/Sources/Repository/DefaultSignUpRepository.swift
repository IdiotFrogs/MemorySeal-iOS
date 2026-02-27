//
//  DefaultSignUpRepository.swift
//  SignUpData
//
//  Created by 선민재 on 2/27/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import BaseData
import SignUpDomain

public final class DefaultSignUpRepository: SignUpRepository {

    private let provider: DefaultProvider<SignUpTargetType>

    public init(provider: DefaultProvider<SignUpTargetType>) {
        self.provider = provider
    }

    public func signUp(nickname: String, profileImage: String) async throws {
        let result = await provider.request(.signUp(nickname: nickname, profileImage: profileImage))

        try ResultHandler.handleResult(
            result: result,
            errorType: SignUpError.self
        )
    }
}
