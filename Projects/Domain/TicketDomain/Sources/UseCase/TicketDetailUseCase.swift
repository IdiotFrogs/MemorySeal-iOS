import Foundation

public protocol TicketDetailUseCase {
    func fetchDetail(capsuleId: Int) async throws -> TicketDetailEntity
}

public final class DefaultTicketDetailUseCase: TicketDetailUseCase {

    private let ticketDetailRepository: TicketDetailRepository

    public init(ticketDetailRepository: TicketDetailRepository) {
        self.ticketDetailRepository = ticketDetailRepository
    }

    public func fetchDetail(capsuleId: Int) async throws -> TicketDetailEntity {
        return try await ticketDetailRepository.fetchDetail(capsuleId: capsuleId)
    }
}
