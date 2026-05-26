import Foundation

public protocol AddMemberRepository {
    func inviteToTimeCapsule(capsuleId: Int) async throws -> String
}
