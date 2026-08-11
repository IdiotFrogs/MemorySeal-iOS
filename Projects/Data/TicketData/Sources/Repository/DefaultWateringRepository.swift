import Foundation

import BaseData
import TicketDomain

public final class DefaultWateringRepository: WateringRepository {

    private let provider: DefaultProvider<WateringTargetType>

    public init(provider: DefaultProvider<WateringTargetType>) {
        self.provider = provider
    }

    public func fetchWaterings(
        capsuleId: Int,
        page: Int,
        size: Int
    ) async throws -> WateringEntity {
        let result = await provider.request(.fetchWaterings(capsuleId: capsuleId, page: page, size: size))

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: WateringResponseDTO.self,
            errorType: WateringError.self
        )

        return responseDTO.toDomain
    }

    public func water(capsuleId: Int) async throws {
        let result = await provider.request(.water(capsuleId: capsuleId))
        try ResultHandler.handleResult(result: result, errorType: WateringError.self)
    }
}
