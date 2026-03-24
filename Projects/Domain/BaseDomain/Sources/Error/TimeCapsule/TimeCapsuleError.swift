//
//  TimeCapsuleError.swift
//  BaseDomain
//
//  Created by 선민재 on 3/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

public enum TimeCapsuleError: DomainError {
    case defaultError

    public init(statusCode: Int) {
        self = .defaultError
    }
}
