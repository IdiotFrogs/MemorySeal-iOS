import Foundation
import Moya

import BaseData

public enum WateringTargetType {
    case fetchWaterings(capsuleId: Int, page: Int, size: Int)
    case water(capsuleId: Int)
}

extension WateringTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .fetchWaterings(let capsuleId, _, _):
            return "/time-capsules/\(capsuleId)/water"
        case .water(let capsuleId):
            return "/time-capsules/\(capsuleId)/water"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .fetchWaterings:
            return .get
        case .water:
            return .post
        }
    }

    public var task: Moya.Task {
        switch self {
        case .fetchWaterings(_, let page, let size):
            return .requestParameters(
                parameters: ["page": page, "size": size],
                encoding: URLEncoding.queryString
            )
        case .water:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        return nil
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .fetchWaterings, .water:
            return true
        }
    }
}
