import BaseDomain

public enum WateringError: DomainError {
    case defaultError

    public init(errorResponse: BaseDomain.ErrorResponseEntity) {
        self = .defaultError
    }
}
