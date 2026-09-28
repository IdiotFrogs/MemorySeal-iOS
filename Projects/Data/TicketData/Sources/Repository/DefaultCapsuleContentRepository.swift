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

    public func fetchCapsuleContents(
        capsuleId: Int,
        page: Int,
        size: Int
    ) async throws -> CapsuleContentGroupPageEntity {
        let result = await provider.request(
            .fetchCapsuleContents(capsuleId: capsuleId, page: page, size: size)
        )

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: CapsuleContentListResponseDTO.self,
            errorType: CapsuleContentError.self
        )

        return responseDTO.toDomain
    }

    public func fetchMyContents(capsuleId: Int) async throws -> [CapsuleContent] {
        let result = await provider.request(.fetchMyCapsuleContents(capsuleId: capsuleId))

        let responseDTOs = try ResultHandler.handleResult(
            result: result,
            responseType: [MyCapsuleContentResponseDTO].self,
            errorType: CapsuleContentError.self
        )

        return responseDTOs.map { $0.toDomain }
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

    public func updateTextContent(contentId: Int, content: String) async throws -> CapsuleContent {
        let result = await provider.request(.updateTextContent(contentId: contentId, content: content))

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: CreateCapsuleContentResponseDTO.self,
            errorType: CapsuleContentError.self
        )

        return responseDTO.toDomain
    }

    public func deleteContents(contentIds: [Int], fileIds: [Int]) async throws {
        let result = await provider.request(.deleteContents(contentIds: contentIds, fileIds: fileIds))

        try ResultHandler.handleResult(
            result: result,
            errorType: CapsuleContentError.self
        )
    }
}
