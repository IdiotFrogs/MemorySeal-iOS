import Foundation

import BaseData
import HomeDomain

public final class DefaultEnterTicketRepository: EnterTicketRepository {

    private let provider: DefaultProvider<EnterTicketTargetType>

    public init(provider: DefaultProvider<EnterTicketTargetType>) {
        self.provider = provider
    }

    public func joinRequest(code: String) async throws -> Int {
        let result = await provider.request(.joinRequest(code: code))

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: JoinTicketResponseDTO.self,
            errorType: EnterTicketError.self
        )

        guard let capsuleId = responseDTO.toDomain else {
            throw EnterTicketError.defaultError
        }
        return capsuleId
    }
}
