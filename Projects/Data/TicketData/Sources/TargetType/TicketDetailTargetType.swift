import Foundation
import Moya

import BaseData

public enum TicketDetailTargetType {
    case fetchDetail(capsuleId: Int)
}

extension TicketDetailTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .fetchDetail(let capsuleId):
            return "/time-capsules/\(capsuleId)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .fetchDetail:
            return .get
        }
    }

    public var task: Moya.Task {
        switch self {
        case .fetchDetail:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        return nil
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .fetchDetail:
            return true
        }
    }
}
