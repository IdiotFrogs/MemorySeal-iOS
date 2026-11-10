import Foundation

import BaseDomain

public enum BuryTicketError: DomainError, LocalizedError {
    case defaultError
    case pastOpenDate
    case alreadyBuried

    public var errorDescription: String? {
        switch self {
        case .pastOpenDate:
            return "오픈일은 오늘 이후 날짜로 설정해 주세요."
        case .alreadyBuried:
            return "이미 묻힌 티켓입니다."
        case .defaultError:
            return "티켓을 묻는 중 오류가 발생했습니다."
        }
    }

    public init(errorResponse: BaseDomain.ErrorResponseEntity) {
        switch errorResponse.status {
        case 400:
            self = .pastOpenDate
        case 409:
            self = .alreadyBuried
        default:
            self = .defaultError
        }
    }
}
