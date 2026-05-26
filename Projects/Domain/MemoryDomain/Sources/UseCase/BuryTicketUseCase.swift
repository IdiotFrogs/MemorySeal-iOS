import Foundation

public protocol BuryTicketUseCase {
    func buryTimeCapsule(capsuleId: Int, openedAt: Date) async throws
}

public final class DefaultBuryTicketUseCase: BuryTicketUseCase {
    private let buryTicketRepository: BuryTicketRepository

    public init(buryTicketRepository: BuryTicketRepository) {
        self.buryTicketRepository = buryTicketRepository
    }

    public func buryTimeCapsule(capsuleId: Int, openedAt: Date) async throws {
        try await buryTicketRepository.buryTimeCapsule(capsuleId: capsuleId, openedAt: openedAt)
    }
}
