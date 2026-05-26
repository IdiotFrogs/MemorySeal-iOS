import Foundation

import BaseData
import MemoryDomain

public final class DefaultManageTicketRepository: ManageTicketRepository {

    private let provider: DefaultProvider<ManageTicketTargetType>

    public init(provider: DefaultProvider<ManageTicketTargetType>) {
        self.provider = provider
    }

    public func deleteTimeCapsule(capsuleId: Int) async throws {
        let result = await provider.request(.deleteTimeCapsule(capsuleId: capsuleId))
        try ResultHandler.handleResult(result: result, errorType: ManageTicketError.self)
    }

    public func leaveTimeCapsule(capsuleId: Int) async throws {
        let result = await provider.request(.leaveTimeCapsule(capsuleId: capsuleId))
        try ResultHandler.handleResult(result: result, errorType: ManageTicketError.self)
    }
}
