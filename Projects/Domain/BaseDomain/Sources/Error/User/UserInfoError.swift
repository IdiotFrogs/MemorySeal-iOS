//
//  UserInfoError.swift
//  UserDomain
//
//  Created by 선민재 on 2/10/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import BaseDomain

public enum UserInfoError: DomainError {
    case defaultError
    
    public init(errorResponse: BaseDomain.ErrorResponseEntity) {
        self = .defaultError
    }
}
