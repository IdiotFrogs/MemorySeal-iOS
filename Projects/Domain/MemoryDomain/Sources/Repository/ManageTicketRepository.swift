import Foundation

public protocol ManageTicketRepository {
    func leaveTimeCapsule(capsuleId: Int) async throws
}
