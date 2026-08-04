import Foundation

import BaseData
import TicketDomain

public final class DefaultJoinCapsuleRepository: JoinCapsuleRepository {

    private let provider: DefaultProvider<JoinCapsuleTargetType>

    public init(provider: DefaultProvider<JoinCapsuleTargetType>) {
        self.provider = provider
    }

    public func join(capsuleId: Int) async throws {
        let result = await provider.request(.join(capsuleId: capsuleId))
        try ResultHandler.handleResult(result: result, errorType: JoinCapsuleError.self)
    }
}
