import Foundation

public protocol BuryTicketRepository {
    func buryTimeCapsule(capsuleId: Int, openedAt: String) async throws
}
