import Foundation

public protocol ManageTicketRepository {
    func deleteTimeCapsule(capsuleId: Int) async throws
    func leaveTimeCapsule(capsuleId: Int) async throws
}
