import Foundation

import BaseData
import MemoryDomain

public final class DefaultBuryTicketRepository: BuryTicketRepository {

    private let provider: DefaultProvider<BuryTicketTargetType>

    public init(provider: DefaultProvider<BuryTicketTargetType>) {
        self.provider = provider
    }

    public func buryTimeCapsule(capsuleId: Int, openedAt: Date) async throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let openedAtString = formatter.string(from: openedAt)

        let requestDTO = BuryTicketRequestDTO(openedAt: openedAtString)
        let result = await provider.request(
            .buryTimeCapsule(capsuleId: capsuleId, requestDTO: requestDTO)
        )
        try ResultHandler.handleResult(result: result, errorType: BuryTicketError.self)
    }
}
