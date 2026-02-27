//
//  SignUpRepository.swift
//  SignUpDomain
//
//  Created by 선민재 on 2/27/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

public protocol SignUpRepository {
    func signUp(nickname: String, profileImage: String) async throws
}
