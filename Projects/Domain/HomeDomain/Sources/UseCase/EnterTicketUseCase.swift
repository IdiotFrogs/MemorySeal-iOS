import Foundation

public protocol EnterTicketUseCase {
    func joinRequest(code: String) async throws -> Int
}

public final class DefaultEnterTicketUseCase: EnterTicketUseCase {
    private let enterTicketRepository: EnterTicketRepository

    public init(enterTicketRepository: EnterTicketRepository) {
        self.enterTicketRepository = enterTicketRepository
    }

    public func joinRequest(code: String) async throws -> Int {
        return try await enterTicketRepository.joinRequest(code: code)
    }
}
