import Foundation

public protocol EnterTicketRepository {
    func joinRequest(code: String) async throws
}
