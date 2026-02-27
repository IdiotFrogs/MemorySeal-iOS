//
//  SignUpTargetType.swift
//  AuthData
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation
import Moya

import BaseData

public enum SignUpTargetType {
    case signUp(nickname: String, profileImage: String)
}

extension SignUpTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .signUp:
            return "/users/sign-up"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .signUp:
            return .patch
        }
    }

    public var task: Moya.Task {
        switch self {
        case .signUp(let nickname, let profileImage):
            return .requestCompositeParameters(
                bodyParameters: ["profileImage": profileImage],
                bodyEncoding: JSONEncoding.default,
                urlParameters: ["nickname": nickname]
            )
        }
    }

    public var headers: [String: String]? {
        return nil
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .signUp:
            return true
        }
    }
}
