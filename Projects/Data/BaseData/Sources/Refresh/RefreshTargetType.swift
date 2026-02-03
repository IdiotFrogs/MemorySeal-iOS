//
//  RefreshTargetType.swift
//  BaseData
//
//  Created by 선민재 on 2/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//


import Foundation
import Moya

public enum RefreshTargetType {
    case refreshAccessToken(refreshToken: String)
}

extension RefreshTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .refreshAccessToken:
            return "/auth/reissue"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .refreshAccessToken:
            return .post
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .refreshAccessToken:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case let .refreshAccessToken(refreshToken):
            return ["Authorization": refreshToken]
        }
    }
    
    public var isNeededAccessToken: Bool {
        return false
    }
}
