import Foundation

import BaseData
import TicketDomain

public final class DefaultJoinCapsuleRepository: JoinCapsuleRepository {

    private let provider: DefaultProvider<JoinCapsuleTargetType>

    public init(provider: DefaultProvider<JoinCapsuleTargetType>) {
        self.provider = provider
    }

    public func join(capsuleId: Int) async throws -> Bool {
        let result = await provider.request(.join(capsuleId: capsuleId))

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: JoinCapsuleResponseDTO.self,
            errorType: JoinCapsuleError.self
        )

        return responseDTO.animationShown ?? false
    }
}
