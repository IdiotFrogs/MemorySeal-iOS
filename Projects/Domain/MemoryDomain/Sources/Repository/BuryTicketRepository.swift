import Foundation

public protocol BuryTicketRepository {
    func buryTimeCapsule(capsuleId: Int, openedAt: Date) async throws
}
