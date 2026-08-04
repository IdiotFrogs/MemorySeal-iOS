import Foundation

public protocol JoinCapsuleRepository {
    func join(capsuleId: Int) async throws
}
