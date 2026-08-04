import BaseDomain

public enum JoinCapsuleError: DomainError {
    case defaultError

    public init(errorResponse: ErrorResponseEntity) {
        self = .defaultError
    }
}
