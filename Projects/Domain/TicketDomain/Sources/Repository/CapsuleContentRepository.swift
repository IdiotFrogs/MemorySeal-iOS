import Foundation

public protocol CapsuleContentRepository {
    func fetchCapsuleContents(capsuleId: Int, page: Int, size: Int) async throws -> CapsuleContentGroupPageEntity
    func fetchMyContents(capsuleId: Int) async throws -> [CapsuleContent]
    func fetchCurrentUserId() -> Int?
    func createTextContent(capsuleId: Int, content: String) async throws -> CapsuleContent
    func createPhotoContent(capsuleId: Int, images: [Data]) async throws -> CapsuleContent
    func deleteContent(contentId: Int) async throws
}
