import Foundation
import Moya

import BaseData

public enum CapsuleContentTargetType {
    case fetchCapsuleContents(capsuleId: Int)
}

extension CapsuleContentTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .fetchCapsuleContents(let capsuleId):
            return "/api/time-capsule-content/\(capsuleId)/contents"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .fetchCapsuleContents:
            return .get
        }
    }

    public var task: Moya.Task {
        switch self {
        case .fetchCapsuleContents:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        return nil
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .fetchCapsuleContents:
            return true
        }
    }
}
