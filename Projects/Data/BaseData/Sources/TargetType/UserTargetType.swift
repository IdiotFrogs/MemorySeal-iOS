//
//  UserTargetType.swift
//  AuthData
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation
import Moya

public enum UserTargetType {
    case userInfo
    case uploadProfileImage(userId: Int, file: String)
}

extension UserTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .userInfo:
            return "/users/me"
        case .uploadProfileImage:
            return "/s3/upload/profile-image"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .userInfo:
            return .get
        case .uploadProfileImage:
            return .post
        }
    }

    public var task: Moya.Task {
        switch self {
        case .userInfo:
            return .requestPlain
        case .uploadProfileImage(let userId, let file):
            return .requestCompositeParameters(
                bodyParameters: ["file": file],
                bodyEncoding: JSONEncoding.default,
                urlParameters: ["userId": userId]
            )
        }
    }

    public var headers: [String : String]? {
        return nil
    }

    public var validationType: ValidationType {
        return .successCodes
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .userInfo:
            return true
        case .uploadProfileImage:
            return true
        }
    }
}
