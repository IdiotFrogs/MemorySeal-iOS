import Foundation
import Moya

import BaseData

public enum JoinCapsuleTargetType {
    case join(capsuleId: Int)
}

extension JoinCapsuleTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .join(let capsuleId):
            return "/time-capsules/\(capsuleId)/join"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .join:
            return .post
        }
    }

    public var task: Moya.Task {
        switch self {
        case .join:
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
        case .join:
            return true
        }
    }
}
