//
//  EditProfileError.swift
//  BaseDomain
//
//  Created by 선민재 on 3/25/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public enum EditProfileError: DomainError, LocalizedError {
    case defaultError
    case duplicateNickname

    public var errorDescription: String? {
        switch self {
        case .defaultError:
            return "프로필 수정에 실패했습니다. 다시 시도해주세요."
        case .duplicateNickname:
            return "이미 사용 중인 별명입니다."
        }
    }

    public init(errorResponse: BaseDomain.ErrorResponseEntity) {
        switch errorResponse.error {
        case "DUPLICATE_NICKNAME":
            self = .duplicateNickname
        default:
            self = .defaultError
        }
    }
}
