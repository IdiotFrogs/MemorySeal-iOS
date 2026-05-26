import Foundation

public struct BuryTicketRequestDTO: Encodable {
    let openedAt: String

    public init(openedAt: String) {
        self.openedAt = openedAt
    }
}
