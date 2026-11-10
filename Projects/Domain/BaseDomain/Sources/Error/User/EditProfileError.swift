//
//  EditProfileError.swift
//  BaseDomain
//
//  Created by 선민재 on 3/25/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

public enum EditProfileError: DomainError {
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
