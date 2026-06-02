import Foundation
import Moya

import BaseData

public enum AddMemberTargetType {
    case inviteToTimeCapsule(capsuleId: Int)
    case fetchCollaborators(capsuleId: Int)
    case delegateHost(capsuleId: Int, targetUserId: Int)
    case kickContributor(capsuleId: Int, targetUserId: Int)
}

extension AddMemberTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .inviteToTimeCapsule(let capsuleId):
            return "/time-capsules/\(capsuleId)/invite"
        case .fetchCollaborators(let capsuleId):
            return "/time-capsules/\(capsuleId)/collaborators"
        case .delegateHost(let capsuleId, let targetUserId):
            return "/time-capsules/\(capsuleId)/delegation/\(targetUserId)"
        case .kickContributor(let capsuleId, let targetUserId):
            return "/time-capsules/\(capsuleId)/contributors/\(targetUserId)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .inviteToTimeCapsule:
            return .post
        case .fetchCollaborators:
            return .get
        case .delegateHost:
            return .put
        case .kickContributor:
            return .delete
        }
    }

    public var task: Moya.Task {
        switch self {
        case .inviteToTimeCapsule, .fetchCollaborators, .delegateHost, .kickContributor:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        return nil
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .inviteToTimeCapsule, .fetchCollaborators, .delegateHost, .kickContributor:
            return true
        }
    }
}
