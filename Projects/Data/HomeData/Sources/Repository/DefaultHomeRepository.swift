import Foundation

import BaseData
import BaseDomain
import HomeDomain

public final class DefaultHomeRepository: HomeRepository {

    private let provider: DefaultProvider<HomeTargetType>

    public init(provider: DefaultProvider<HomeTargetType>) {
        self.provider = provider
    }

    public func fetchMyTimeCapsules() async throws -> [TimeCapsuleEntity] {
        let result = await provider.request(.fetchMyTimeCapsules)

        let responseDTOs = try ResultHandler.handleResult(
            result: result,
            responseType: [TimeCapsuleResponseDTO].self,
            errorType: HomeError.self
        )

        return responseDTOs.map { $0.toDomain }
    }
}
