//
//  TimeCapsuleTargetType.swift
//  BaseData
//
//  Created by 선민재 on 3/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation
import Moya

public enum TimeCapsuleTargetType {
    case fetchMyTimeCapsules
}

extension TimeCapsuleTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .fetchMyTimeCapsules:
            return "/time-capsules/my"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .fetchMyTimeCapsules:
            return .get
        }
    }

    public var task: Moya.Task {
        switch self {
        case .fetchMyTimeCapsules:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        return nil
    }

    public var validationType: ValidationType {
        return .successCodes
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .fetchMyTimeCapsules:
            return true
        }
    }
}
