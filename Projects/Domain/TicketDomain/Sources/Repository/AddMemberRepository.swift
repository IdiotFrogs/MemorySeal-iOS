import Foundation

public protocol AddMemberRepository {
    func inviteToTimeCapsule(capsuleId: Int) async throws -> String
    func fetchCollaborators(capsuleId: Int, page: Int, size: Int) async throws -> CollaboratorPageEntity
    func searchCollaborators(capsuleId: Int, nickname: String) async throws -> [CollaboratorEntity]
    func delegateHost(capsuleId: Int, targetUserId: Int) async throws
    func kickContributor(capsuleId: Int, targetUserId: Int) async throws
}
