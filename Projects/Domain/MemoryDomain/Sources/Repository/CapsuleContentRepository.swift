import Foundation

public protocol CapsuleContentRepository {
    func fetchCapsuleContents(capsuleId: Int) async throws -> [CapsuleContentGroupEntity]
    func fetchCurrentUserId() -> Int?
}
