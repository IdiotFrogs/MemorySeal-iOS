//
//  AuthError.swift
//  AuthDomain
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import BaseDomain

public enum AuthError: DomainError {
    case defaultError
    
    public init() {
        self = .defaultError
    }
}
