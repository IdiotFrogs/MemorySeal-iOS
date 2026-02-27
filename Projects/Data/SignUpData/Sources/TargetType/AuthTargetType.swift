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

public enum AuthTargetType {
    case signIn(_ requestDTO: SignInRequestDTO)
}

extension AuthTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .signIn:
            return "/auth/login/google"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .signIn:
            return .post
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case let .signIn(requestDTO):
            return .requestJSONEncodable(requestDTO)
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .signIn:
            return nil
        }
    }
    
    public var isNeededAccessToken: Bool {
        switch self {
        case .signIn:
            return false
        }
    }
}
