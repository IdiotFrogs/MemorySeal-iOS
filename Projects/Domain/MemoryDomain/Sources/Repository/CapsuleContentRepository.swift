import Foundation

public protocol CapsuleContentRepository {
    func fetchCapsuleContents(capsuleId: Int) async throws -> [CapsuleContentGroupEntity]
    func fetchCurrentUserId() -> Int?
    func createTextContent(capsuleId: Int, content: String) async throws -> CapsuleContent
    func createPhotoContent(capsuleId: Int, images: [Data]) async throws -> CapsuleContent
}
