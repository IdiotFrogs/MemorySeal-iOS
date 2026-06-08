import Foundation
import Moya

import BaseData

public enum BuryTicketTargetType {
    case buryTimeCapsule(capsuleId: Int, requestDTO: BuryTicketRequestDTO)
}

extension BuryTicketTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .buryTimeCapsule(let capsuleId, _):
            return "/time-capsules/\(capsuleId)/bury"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .buryTimeCapsule:
            return .put
        }
    }

    public var task: Moya.Task {
        switch self {
        case .buryTimeCapsule(_, let requestDTO):
            return .requestJSONEncodable(requestDTO)
        }
    }

    public var headers: [String: String]? {
        return nil
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .buryTimeCapsule:
            return true
        }
    }
}
