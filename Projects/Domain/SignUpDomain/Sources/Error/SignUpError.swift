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
    case duplicateNickname

    public init(errorResponse: BaseDomain.ErrorResponseEntity) {
        switch errorResponse.error {
        case "DUPLICATE_NICKNAME":
            self = .duplicateNickname
        default:
            self = .defaultError
        }
    }
}
