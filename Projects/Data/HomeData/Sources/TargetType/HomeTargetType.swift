import Foundation
import Moya

import BaseData

public enum HomeTargetType {
    case fetchMyTimeCapsules(status: String?, page: Int, size: Int)
    case fetchUnopenedTimeCapsules
    case fetchSeasonalBanner
}

extension HomeTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .fetchMyTimeCapsules:
            return "/time-capsules/my"
        case .fetchUnopenedTimeCapsules:
            return "/time-capsules/unopened"
        case .fetchSeasonalBanner:
            return "/banners/seasonal"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .fetchMyTimeCapsules, .fetchUnopenedTimeCapsules, .fetchSeasonalBanner:
            return .get
        }
    }

    public var task: Moya.Task {
        switch self {
        case .fetchMyTimeCapsules(let status, let page, let size):
            var parameters: [String: Any] = ["page": page, "size": size]
            if let status {
                parameters["status"] = status
            }
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )

        case .fetchUnopenedTimeCapsules, .fetchSeasonalBanner:
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
        case .fetchMyTimeCapsules, .fetchUnopenedTimeCapsules, .fetchSeasonalBanner:
            return true
        }
    }
}
