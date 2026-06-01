import Foundation

import BaseData
import MemoryDomain

public final class DefaultBuryTicketRepository: BuryTicketRepository {

    private let provider: DefaultProvider<BuryTicketTargetType>

    public init(provider: DefaultProvider<BuryTicketTargetType>) {
        self.provider = provider
    }

    public func buryTimeCapsule(capsuleId: Int, openedAt: Date) async throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "UTC") ?? .current
        let components = calendar.dateComponents(
            [.nanosecond],
            from: openedAt
        )
        let nanoseconds = components.nanosecond ?? 0

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let basePart = formatter.string(from: openedAt)

        let openedAtString = String(format: "%@.%09d", basePart, nanoseconds)

        let requestDTO = BuryTicketRequestDTO(openedAt: openedAtString)
        let result = await provider.request(
            .buryTimeCapsule(capsuleId: capsuleId, requestDTO: requestDTO)
        )
        try ResultHandler.handleResult(result: result, errorType: BuryTicketError.self)
    }
}
