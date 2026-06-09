import Foundation

import BaseData
import TicketDomain

public final class DefaultTicketDetailRepository: TicketDetailRepository {

    private let provider: DefaultProvider<TicketDetailTargetType>

    public init(provider: DefaultProvider<TicketDetailTargetType>) {
        self.provider = provider
    }

    public func fetchDetail(capsuleId: Int) async throws -> TicketDetailEntity {
        let result = await provider.request(.fetchDetail(capsuleId: capsuleId))
        let dto = try ResultHandler.handleResult(
            result: result,
            responseType: TicketDetailResponseDTO.self,
            errorType: TicketDetailError.self
        )
        return dto.toDomain
    }
}
