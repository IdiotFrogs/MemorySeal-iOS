import BaseDomain

public enum ManageTicketError: DomainError {
    case defaultError

    public init(errorResponse: BaseDomain.ErrorResponseEntity) {
        self = .defaultError
    }
}
