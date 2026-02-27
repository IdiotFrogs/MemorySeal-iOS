//
//  SignUpError.swift
//  SignUpDomain
//
//  Created by 선민재 on 2/27/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import BaseDomain

public enum SignUpError: DomainError {
    case defaultError

    public init(statusCode: Int) {
        self = .defaultError
    }
}
