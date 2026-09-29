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
import SignInDomain

public enum AuthTargetType {
    case signIn(_ requestDTO: SignInRequestDTO, type: SignInType)
    case logout
    case updateFCMToken(fcmToken: String)
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
        case .updateFCMToken:
            return "/auth/fcm-token"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .signIn:
            return .post
        case .logout:
            return .delete
        case .updateFCMToken:
            return .put
        }
    }

    public var task: Moya.Task {
        switch self {
        case let .signIn(requestDTO, _):
            return .requestJSONEncodable(requestDTO)
        case .logout:
            return .requestPlain
        case let .updateFCMToken(fcmToken):
            return .requestParameters(
                parameters: ["fcmToken": fcmToken],
                encoding: URLEncoding.queryString
            )
        }
    }

    public var headers: [String : String]? {
        switch self {
        case .signIn:
            return nil
        case .logout:
            return nil
        case .updateFCMToken:
            return nil
        }
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .signIn:
            return false
        case .logout:
            return true
        case .updateFCMToken:
            return true
        }
    }
}
