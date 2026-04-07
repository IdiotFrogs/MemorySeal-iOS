//
//  UploadProfileImageError.swift
//  BaseDomain
//
//  Created by 선민재 on 2/27/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

public enum UploadProfileImageError: DomainError {
    case defaultError

    public init(errorResponse: BaseDomain.ErrorResponseEntity) {
        self = .defaultError
    }
}
