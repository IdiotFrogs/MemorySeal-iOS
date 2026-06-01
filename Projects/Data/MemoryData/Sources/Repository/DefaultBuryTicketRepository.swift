import Foundation

import BaseData
import MemoryDomain

public final class DefaultBuryTicketRepository: BuryTicketRepository {

    private let provider: DefaultProvider<BuryTicketTargetType>

    public init(provider: DefaultProvider<BuryTicketTargetType>) {
        self.provider = provider
    }

    public func buryTimeCapsule(capsuleId: Int, openedAt: String) async throws {
        let requestDTO = BuryTicketRequestDTO(openedAt: openedAt)
        let result = await provider.request(
            .buryTimeCapsule(capsuleId: capsuleId, requestDTO: requestDTO)
        )
        try ResultHandler.handleResult(result: result, errorType: BuryTicketError.self)
    }
}
