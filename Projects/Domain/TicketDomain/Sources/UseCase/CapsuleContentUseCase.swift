import Foundation

public protocol CapsuleContentUseCase {
    func fetchGroupPage(capsuleId: Int, page: Int, size: Int) async throws -> CapsuleContentGroupPageEntity
    func fetchMyContents(capsuleId: Int) async throws -> [CapsuleContent]
    func createText(capsuleId: Int, content: String) async throws -> CapsuleContent
    func createPhotos(capsuleId: Int, images: [Data]) async throws -> CapsuleContent
    func delete(contentId: Int) async throws
}

public final class DefaultCapsuleContentUseCase: CapsuleContentUseCase {

    private let capsuleContentRepository: CapsuleContentRepository

    public init(capsuleContentRepository: CapsuleContentRepository) {
        self.capsuleContentRepository = capsuleContentRepository
    }

    public func fetchGroupPage(
        capsuleId: Int,
        page: Int,
        size: Int
    ) async throws -> CapsuleContentGroupPageEntity {
        return try await capsuleContentRepository.fetchCapsuleContents(
            capsuleId: capsuleId,
            page: page,
            size: size
        )
    }

    public func fetchMyContents(capsuleId: Int) async throws -> [CapsuleContent] {
        return try await capsuleContentRepository.fetchMyContents(capsuleId: capsuleId)
    }

    public func createText(capsuleId: Int, content: String) async throws -> CapsuleContent {
        return try await capsuleContentRepository.createTextContent(capsuleId: capsuleId, content: content)
    }

    public func createPhotos(capsuleId: Int, images: [Data]) async throws -> CapsuleContent {
        return try await capsuleContentRepository.createPhotoContent(capsuleId: capsuleId, images: images)
    }

    public func delete(contentId: Int) async throws {
        try await capsuleContentRepository.deleteContent(contentId: contentId)
    }
}
