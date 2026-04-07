//
//  RefreshError.swift
//  BaseDomain
//
//  Created by 선민재 on 2/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public enum RefreshError: DomainError {
    case defaultError
    case tokenExpired
    case notFoundUser
    
    public init(errorResponse: ErrorResponseEntity) {
        switch errorResponse.error {
        case "EXPIRED_TOKEN":
            self = .tokenExpired
        case "USER_NOT_FOUND":
            self = .notFoundUser
        default:
            self = .defaultError
        }
    }
}
