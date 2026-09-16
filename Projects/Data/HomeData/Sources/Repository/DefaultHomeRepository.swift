import Foundation

import BaseData
import BaseDomain
import HomeDomain

public final class DefaultHomeRepository: HomeRepository {

    private let provider: DefaultProvider<HomeTargetType>

    public init(provider: DefaultProvider<HomeTargetType>) {
        self.provider = provider
    }

    public func fetchMyTimeCapsules(
        status: TimeCapsuleStatus?,
        page: Int,
        size: Int
    ) async throws -> TimeCapsulePageEntity {
        let result = await provider.request(
            .fetchMyTimeCapsules(status: status?.rawValue, page: page, size: size)
        )

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: TimeCapsulePageResponseDTO.self,
            errorType: HomeError.self
        )

        return responseDTO.toDomain
    }

    public func fetchUnopenedTimeCapsules() async throws -> [TimeCapsuleEntity] {
        let result = await provider.request(.fetchUnopenedTimeCapsules)

        let responseDTOs = try ResultHandler.handleResult(
            result: result,
            responseType: [UnopenedTimeCapsuleResponseDTO].self,
            errorType: HomeError.self
        )

        return responseDTOs.map { $0.toDomain }
    }

    public func fetchSeasonalBanner() async throws -> SeasonalBannerEntity {
        let result = await provider.request(.fetchSeasonalBanner)

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: SeasonalBannerResponseDTO.self,
            errorType: HomeError.self
        )

        return responseDTO.toDomain
    }
}
