import Foundation

import BaseData
import HomeDomain

public final class DefaultEnterTicketRepository: EnterTicketRepository {

    private let provider: DefaultProvider<EnterTicketTargetType>

    public init(provider: DefaultProvider<EnterTicketTargetType>) {
        self.provider = provider
    }

    public func joinRequest(code: String) async throws {
        let result = await provider.request(.joinRequest(code: code))
        try ResultHandler.handleResult(result: result, errorType: EnterTicketError.self)
    }
}
