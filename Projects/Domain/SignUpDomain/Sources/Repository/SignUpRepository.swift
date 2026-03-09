//
//  SignUpRepository.swift
//  SignUpDomain
//
//  Created by 선민재 on 2/27/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public protocol SignUpRepository {
    func signUp(nickname: String, profileImage: Data) async throws
}
