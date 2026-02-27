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
    
    public init(statusCode: Int) {
        switch statusCode {
        case 401:
            self = .tokenExpired
        default:
            self = .defaultError
        }
    }
}
