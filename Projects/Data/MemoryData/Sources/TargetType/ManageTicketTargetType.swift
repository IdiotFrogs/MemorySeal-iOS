import Foundation
import Moya

import BaseData

public enum ManageTicketTargetType {
    case leaveTimeCapsule(capsuleId: Int)
}

extension ManageTicketTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .leaveTimeCapsule(let capsuleId):
            return "/time-capsules/\(capsuleId)/leave"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .leaveTimeCapsule:
            return .delete
        }
    }

    public var task: Moya.Task {
        switch self {
        case .leaveTimeCapsule:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        return nil
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .leaveTimeCapsule:
            return true
        }
    }
}
