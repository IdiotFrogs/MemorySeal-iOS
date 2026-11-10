import BaseDomain

public enum AddMemberError: DomainError {
    case defaultError
    case cannotDelegateToWithdrawnUser

    public init(errorResponse: BaseDomain.ErrorResponseEntity) {
        switch errorResponse.error {
        case "CANNOT_DELEGATE_TO_WITHDRAWN_USER":
            self = .cannotDelegateToWithdrawnUser
        default:
            self = .defaultError
        }
    }
}
