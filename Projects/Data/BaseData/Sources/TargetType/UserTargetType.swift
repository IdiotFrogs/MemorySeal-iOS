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
}

extension UserTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .userInfo:
            return "/users/me"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .userInfo:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .userInfo:
            return .requestPlain
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
        }
    }
}
