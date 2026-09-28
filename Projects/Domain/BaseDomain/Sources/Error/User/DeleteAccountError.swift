//
//  DeleteAccountError.swift
//  BaseDomain
//
//  Created by 선민재 on 9/29/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

public enum DeleteAccountError: DomainError {
    case defaultError

    public init(errorResponse: BaseDomain.ErrorResponseEntity) {
        self = .defaultError
    }
}
