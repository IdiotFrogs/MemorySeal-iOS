//
//  AuthRepository.swift
//  AuthDomain
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

public protocol AuthRepository {
    func fetchSignIn(idToken: String, authorizationCode: String?, type: SignInType) async throws
}
