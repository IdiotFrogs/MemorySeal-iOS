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
    case inviteToTimeCapsule(capsuleId: Int)
    case joinRequest(code: String)
}

extension TimeCapsuleTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .fetchMyTimeCapsules:
            return "/time-capsules/my"
        case .inviteToTimeCapsule(let capsuleId):
            return "/time-capsules/\(capsuleId)/invite"
        case .joinRequest:
            return "/time-capsules/join-request"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .fetchMyTimeCapsules:
            return .get
        case .inviteToTimeCapsule:
            return .post
        case .joinRequest:
            return .post
        }
    }

    public var task: Moya.Task {
        switch self {
        case .fetchMyTimeCapsules:
            return .requestPlain
        case .inviteToTimeCapsule:
            return .requestPlain
        case .joinRequest(let code):
            return .requestJSONEncodable(["code": code])
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
        case .inviteToTimeCapsule:
            return true
        case .joinRequest:
            return true
        }
    }
}
