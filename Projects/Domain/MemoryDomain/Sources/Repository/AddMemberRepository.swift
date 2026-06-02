import Foundation

public protocol AddMemberRepository {
    func inviteToTimeCapsule(capsuleId: Int) async throws -> String
    func fetchCollaborators(capsuleId: Int) async throws -> [CollaboratorEntity]
    func delegateHost(capsuleId: Int, targetUserId: Int) async throws
    func kickContributor(capsuleId: Int, targetUserId: Int) async throws
}
