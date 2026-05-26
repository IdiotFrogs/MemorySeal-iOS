import Foundation
import Moya

import BaseData

public enum EnterTicketTargetType {
    case joinRequest(code: String)
}

extension EnterTicketTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .joinRequest:
            return "/time-capsules/join-request"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .joinRequest:
            return .post
        }
    }

    public var task: Moya.Task {
        switch self {
        case .joinRequest(let code):
            return .requestJSONEncodable(["code": code])
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
        case .joinRequest:
            return true
        }
    }
}
