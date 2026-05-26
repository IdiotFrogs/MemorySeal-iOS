import Foundation
import Moya

import BaseData

public enum HomeTargetType {
    case fetchMyTimeCapsules
}

extension HomeTargetType: BaseTargetType {
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
