import BaseDomain

public enum HomeError: DomainError {
    case defaultError

    public init(errorResponse: BaseDomain.ErrorResponseEntity) {
        self = .defaultError
    }
}
