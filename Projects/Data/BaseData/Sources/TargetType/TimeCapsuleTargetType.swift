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
    case deleteTimeCapsule(capsuleId: Int)
    case fetchTimeCapsuleDetail(capsuleId: Int)
    case fetchCollaborators(capsuleId: Int)
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
        case .deleteTimeCapsule(let capsuleId):
            return "/time-capsules/\(capsuleId)"
        case .fetchTimeCapsuleDetail(let capsuleId):
            return "/time-capsules/\(capsuleId)"
        case .fetchCollaborators(let capsuleId):
            return "/time-capsules/\(capsuleId)/collaborators"
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
        case .deleteTimeCapsule:
            return .delete
        case .fetchTimeCapsuleDetail:
            return .get
        case .fetchCollaborators:
            return .get
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
        case .deleteTimeCapsule:
            return .requestPlain
        case .fetchTimeCapsuleDetail:
            return .requestPlain
        case .fetchCollaborators:
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
        case .inviteToTimeCapsule:
            return true
        case .joinRequest:
            return true
        case .deleteTimeCapsule:
            return true
        case .fetchTimeCapsuleDetail:
            return true
        case .fetchCollaborators:
            return true
        }
    }
}
