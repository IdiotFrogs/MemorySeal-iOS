import Foundation
import Moya

import BaseData

public enum AddMemberTargetType {
    case inviteToTimeCapsule(capsuleId: Int)
    case fetchCollaborators(capsuleId: Int)
}

extension AddMemberTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .inviteToTimeCapsule(let capsuleId):
            return "/time-capsules/\(capsuleId)/invite"
        case .fetchCollaborators(let capsuleId):
            return "/time-capsules/\(capsuleId)/collaborators"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .inviteToTimeCapsule:
            return .post
        case .fetchCollaborators:
            return .get
        }
    }

    public var task: Moya.Task {
        switch self {
        case .inviteToTimeCapsule, .fetchCollaborators:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        return nil
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .inviteToTimeCapsule, .fetchCollaborators:
            return true
        }
    }
}
