import Foundation

import BaseData
import MemoryDomain

public final class DefaultAddMemberRepository: AddMemberRepository {

    private let provider: DefaultProvider<AddMemberTargetType>

    public init(provider: DefaultProvider<AddMemberTargetType>) {
        self.provider = provider
    }

    public func inviteToTimeCapsule(capsuleId: Int) async throws -> String {
        let result = await provider.request(.inviteToTimeCapsule(capsuleId: capsuleId))

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: InviteCodeResponseDTO.self,
            errorType: AddMemberError.self
        )

        return responseDTO.code
    }

    public func fetchCollaborators(capsuleId: Int) async throws -> [CollaboratorEntity] {
        let result = await provider.request(.fetchCollaborators(capsuleId: capsuleId))

        let responseDTOs = try ResultHandler.handleResult(
            result: result,
            responseType: [CollaboratorResponseDTO].self,
            errorType: AddMemberError.self
        )

        return responseDTOs.map { $0.toDomain }
    }
}
