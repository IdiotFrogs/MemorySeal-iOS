//
//  SignInRequestDTO.swift
//  AuthData
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public struct SignInRequestDTO: Encodable {
    let idToken: String
    let authorizationCode: String?
    let fcmToken: String?
    
    public init(
        idToken: String,
        authorizationCode: String? = nil,
        fcmToken: String?
    ) {
        self.idToken = idToken
        self.authorizationCode = authorizationCode
        self.fcmToken = fcmToken
    }
}
