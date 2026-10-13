//
//  FCMTokenRegistrar.swift
//  SignInFeature
//
//  Created by 선민재 on 10/13/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import SignInData
import SignInDomain
import BaseData

public final class FCMTokenRegistrar {
    public static let shared: FCMTokenRegistrar = FCMTokenRegistrar()

    private let keyChainStorage: KeyChainStorage
    private let authRepository: AuthRepository

    private init() {
        let keyChainStorage: KeyChainStorage = DefaultKeyChainStorage()

        self.keyChainStorage = keyChainStorage
        self.authRepository = DefaultAuthRepository(
            authProvider: DefaultProvider<AuthTargetType>(),
            keyChainStorage: keyChainStorage,
            userDefaultStorage: DefaultUserDefaultStorage()
        )
    }

    public func register(fcmToken: String) {
        keyChainStorage.add(value: fcmToken, forKey: .fcmToken)

        guard authRepository.hasAccessToken() else { return }

        Task { [weak self] in
            guard let self else { return }
            try? await self.authRepository.updateFCMToken()
        }
    }
}
