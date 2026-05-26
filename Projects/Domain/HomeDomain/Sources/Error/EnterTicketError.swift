import Foundation

import BaseDomain

public enum EnterTicketError: DomainError, LocalizedError {
    case defaultError
    case invalidInviteCode
    case timeCapsuleNotFound
    case alreadyRequested
    case alreadyContributor

    public var errorDescription: String? {
        switch self {
        case .defaultError:
            return "요청에 실패했습니다. 다시 시도해주세요."
        case .invalidInviteCode:
            return "유효하지 않거나 만료된 초대 코드입니다."
        case .timeCapsuleNotFound:
            return "타임캡슐을 찾을 수 없습니다."
        case .alreadyRequested:
            return "이미 공동작업자 요청을 보냈습니다."
        case .alreadyContributor:
            return "이미 공동작업자로 등록이 완료된 사용자입니다."
        }
    }

    public init(errorResponse: ErrorResponseEntity) {
        switch errorResponse.error {
        case "INVALID_INVITE_CODE":
            self = .invalidInviteCode
        case "TIMECAPSULE_NOT_FOUND":
            self = .timeCapsuleNotFound
        case "ALREADY_REQUESTED":
            self = .alreadyRequested
        case "ALREADY_CONTRIBUTOR":
            self = .alreadyContributor
        default:
            self = .defaultError
        }
    }
}
