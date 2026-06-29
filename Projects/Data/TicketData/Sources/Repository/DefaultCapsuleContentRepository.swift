import Foundation

import BaseData
import TicketDomain

public final class DefaultCapsuleContentRepository: CapsuleContentRepository {

    private let provider: DefaultProvider<CapsuleContentTargetType>
    private let userDefaultStorage: UserDefaultStorage

    public init(
        provider: DefaultProvider<CapsuleContentTargetType>,
        userDefaultStorage: UserDefaultStorage
    ) {
        self.provider = provider
        self.userDefaultStorage = userDefaultStorage
    }

    public func fetchCapsuleContents(capsuleId: Int) async throws -> [CapsuleContentGroupEntity] {
        let result = await provider.request(.fetchCapsuleContents(capsuleId: capsuleId))

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: CapsuleContentListResponseDTO.self,
            errorType: CapsuleContentError.self
        )

        return responseDTO.content.map { $0.toDomain }
    }

    public func fetchCurrentUserId() -> Int? {
        return userDefaultStorage.get(forKey: .userId) as? Int
    }

    public func createTextContent(capsuleId: Int, content: String) async throws -> CapsuleContent {
        let result = await provider.request(.createTextContent(capsuleId: capsuleId, content: content))

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: CreateCapsuleContentResponseDTO.self,
            errorType: CapsuleContentError.self
        )

        return responseDTO.toDomain
    }

    public func createPhotoContent(capsuleId: Int, images: [Data]) async throws -> CapsuleContent {
        let result = await provider.request(.createPhotoContent(capsuleId: capsuleId, images: images))

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: CreateCapsuleContentResponseDTO.self,
            errorType: CapsuleContentError.self
        )

        return responseDTO.toDomain
    }

    public func deleteContent(contentId: Int) async throws {
        let result = await provider.request(.deleteContent(contentId: contentId))

        try ResultHandler.handleResult(
            result: result,
            errorType: CapsuleContentError.self
        )
    }
}
