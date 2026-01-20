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

enum AuthTargetType {
    case signIn(_ requestDTO: SignInRequestDTO)
}

extension AuthTargetType: BaseTargetType {
    var path: String {
        switch self {
        case .signIn:
            return "/auth/login/google"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signIn:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case let .signIn(requestDTO):
            return .requestJSONEncodable(requestDTO)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .signIn:
            return nil
        }
    }
    
    var isNeededAccessToken: Bool {
        switch self {
        case .signIn:
            return false
        }
    }
}
