//
//  LogoutError.swift
//  SignInDomain
//
//  Created by 선민재 on 7/31/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import BaseDomain

public enum LogoutError: DomainError, LocalizedError {
    case defaultError
    case refreshTokenNotFound

    public var errorDescription: String? {
        switch self {
        case .defaultError:
            return "로그아웃에 실패했습니다. 다시 시도해주세요."
        case .refreshTokenNotFound:
            return "저장된 리프레시 토큰이 없습니다."
        }
    }

    public init(errorResponse: ErrorResponseEntity) {
        switch errorResponse.error {
        case "REFRESHTOKEN_NOT_FOUND":
            self = .refreshTokenNotFound
        default:
            self = .defaultError
        }
    }
}
