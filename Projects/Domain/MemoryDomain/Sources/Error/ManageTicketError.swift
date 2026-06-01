import BaseDomain

public enum ManageTicketError: DomainError {
    case hostCannotLeave
    case defaultError

    public init(errorResponse: BaseDomain.ErrorResponseEntity) {
        switch errorResponse.error {
        case "HOST_CANNOT_LEAVE":
            self = .hostCannotLeave
        default:
            self = .defaultError
        }
    }
}
