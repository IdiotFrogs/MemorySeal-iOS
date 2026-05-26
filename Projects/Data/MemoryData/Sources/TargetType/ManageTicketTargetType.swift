import Foundation
import Moya

import BaseData

public enum ManageTicketTargetType {
    case deleteTimeCapsule(capsuleId: Int)
    case leaveTimeCapsule(capsuleId: Int)
}

extension ManageTicketTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .deleteTimeCapsule(let capsuleId):
            return "/time-capsules/\(capsuleId)"
        case .leaveTimeCapsule(let capsuleId):
            return "/time-capsules/\(capsuleId)/leave"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .deleteTimeCapsule:
            return .delete
        case .leaveTimeCapsule:
            return .delete
        }
    }

    public var task: Moya.Task {
        switch self {
        case .deleteTimeCapsule:
            return .requestPlain
        case .leaveTimeCapsule:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        return nil
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .deleteTimeCapsule:
            return true
        case .leaveTimeCapsule:
            return true
        }
    }
}
