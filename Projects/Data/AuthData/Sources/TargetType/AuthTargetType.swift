//
//  AuthTargetType.swift
//  AuthData
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation
import Moya

import BaseData
import AuthDomain

public enum AuthTargetType {
    case signIn(_ requestDTO: SignInRequestDTO, type: SignInType)
    case logout
}

extension AuthTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case let .signIn(_, type):
            switch type {
            case .apple:
                return "/auth/login/apple"
            case .google:
                return "/auth/login/google"
            }
        case .logout:
            return "/auth/logout"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .signIn:
            return .post
        case .logout:
            return .delete
        }
    }

    public var task: Moya.Task {
        switch self {
        case let .signIn(requestDTO, _):
            return .requestJSONEncodable(requestDTO)
        case .logout:
            return .requestPlain
        }
    }

    public var headers: [String : String]? {
        switch self {
        case .signIn:
            return nil
        case .logout:
            return nil
        }
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .signIn:
            return false
        case .logout:
            return true
        }
    }
}
