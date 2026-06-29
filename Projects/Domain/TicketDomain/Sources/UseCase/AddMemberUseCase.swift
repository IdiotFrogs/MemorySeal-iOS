import Foundation

public protocol AddMemberUseCase {
    func inviteToTimeCapsule(capsuleId: Int) async throws -> String
    func fetchCollaborators(capsuleId: Int) async throws -> [CollaboratorEntity]
    func searchCollaborators(capsuleId: Int, nickname: String) async throws -> [CollaboratorEntity]
    func delegateHost(capsuleId: Int, targetUserId: Int) async throws
    func kickContributor(capsuleId: Int, targetUserId: Int) async throws
}

public final class DefaultAddMemberUseCase: AddMemberUseCase {
    private let addMemberRepository: AddMemberRepository

    public init(addMemberRepository: AddMemberRepository) {
        self.addMemberRepository = addMemberRepository
    }

    public func inviteToTimeCapsule(capsuleId: Int) async throws -> String {
        return try await addMemberRepository.inviteToTimeCapsule(capsuleId: capsuleId)
    }

    public func fetchCollaborators(capsuleId: Int) async throws -> [CollaboratorEntity] {
        return try await addMemberRepository.fetchCollaborators(capsuleId: capsuleId)
    }

    public func searchCollaborators(capsuleId: Int, nickname: String) async throws -> [CollaboratorEntity] {
        return try await addMemberRepository.searchCollaborators(capsuleId: capsuleId, nickname: nickname)
    }

    public func delegateHost(capsuleId: Int, targetUserId: Int) async throws {
        try await addMemberRepository.delegateHost(capsuleId: capsuleId, targetUserId: targetUserId)
    }

    public func kickContributor(capsuleId: Int, targetUserId: Int) async throws {
        try await addMemberRepository.kickContributor(capsuleId: capsuleId, targetUserId: targetUserId)
    }
}
