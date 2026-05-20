import Foundation

import BaseData
import MemoryDomain

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

        let responseDTOs = try ResultHandler.handleResult(
            result: result,
            responseType: [CapsuleContentGroupResponseDTO].self,
            errorType: CapsuleContentError.self
        )

        return responseDTOs.map { $0.toDomain }
    }

    public func fetchCurrentUserId() -> Int? {
        return userDefaultStorage.get(forKey: .userId) as? Int
    }
}
