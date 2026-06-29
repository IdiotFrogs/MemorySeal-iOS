import Foundation

import BaseData
import TicketDomain

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

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: CollaboratorListResponseDTO.self,
            errorType: AddMemberError.self
        )

        return responseDTO.content.map { $0.toDomain }
    }

    public func searchCollaborators(capsuleId: Int, nickname: String) async throws -> [CollaboratorEntity] {
        let result = await provider.request(.searchCollaborators(capsuleId: capsuleId, nickname: nickname))

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: CollaboratorListResponseDTO.self,
            errorType: AddMemberError.self
        )

        return responseDTO.content.map { $0.toDomain }
    }

    public func delegateHost(capsuleId: Int, targetUserId: Int) async throws {
        let result = await provider.request(.delegateHost(capsuleId: capsuleId, targetUserId: targetUserId))
        try ResultHandler.handleResult(result: result, errorType: AddMemberError.self)
    }

    public func kickContributor(capsuleId: Int, targetUserId: Int) async throws {
        let result = await provider.request(.kickContributor(capsuleId: capsuleId, targetUserId: targetUserId))
        try ResultHandler.handleResult(result: result, errorType: AddMemberError.self)
    }
}
