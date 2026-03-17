//
//  CreateTicketError.swift
//  CreateTicketDomain
//
//  Created by 선민재 on 3/17/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import BaseDomain

public enum CreateTicketError: DomainError {
    case defaultError

    public init(statusCode: Int) {
        self = .defaultError
    }
}
