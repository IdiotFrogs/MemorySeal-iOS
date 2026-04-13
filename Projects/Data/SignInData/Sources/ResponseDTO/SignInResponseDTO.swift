//
//  SignInResponseDTO.swift
//  AuthData
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

struct SignInResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}
