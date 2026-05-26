import Foundation
import Moya

import BaseData

public enum AddMemberTargetType {
    case inviteToTimeCapsule(capsuleId: Int)
}

extension AddMemberTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .inviteToTimeCapsule(let capsuleId):
            return "/time-capsules/\(capsuleId)/invite"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .inviteToTimeCapsule:
            return .post
        }
    }

    public var task: Moya.Task {
        switch self {
        case .inviteToTimeCapsule:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        return nil
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .inviteToTimeCapsule:
            return true
        }
    }
}
