import Foundation

public protocol TicketDetailRepository {
    func fetchDetail(capsuleId: Int) async throws -> TicketDetailEntity
}
