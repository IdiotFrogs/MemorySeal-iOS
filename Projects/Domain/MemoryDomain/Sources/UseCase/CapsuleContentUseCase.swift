import Foundation

public protocol CapsuleContentUseCase {
    func execute(capsuleId: Int) async throws -> [CapsuleContent]
}

public final class DefaultCapsuleContentUseCase: CapsuleContentUseCase {

    private let capsuleContentRepository: CapsuleContentRepository

    public init(capsuleContentRepository: CapsuleContentRepository) {
        self.capsuleContentRepository = capsuleContentRepository
    }

    public func execute(capsuleId: Int) async throws -> [CapsuleContent] {
        let groups = try await capsuleContentRepository.fetchCapsuleContents(capsuleId: capsuleId)

        guard let currentUserId = capsuleContentRepository.fetchCurrentUserId() else {
            throw CapsuleContentError.defaultError
        }

        return groups.first { $0.userId == currentUserId }?.contents ?? []
    }
}
