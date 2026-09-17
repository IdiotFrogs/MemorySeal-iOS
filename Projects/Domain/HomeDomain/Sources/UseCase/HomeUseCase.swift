import Foundation

import BaseDomain

public protocol HomeUseCase {
    func fetchTimeCapsules(
        status: TimeCapsuleStatus?,
        page: Int,
        size: Int
    ) async throws -> TimeCapsulePageEntity
    func fetchUnopenedTimeCapsules() async throws -> [TimeCapsuleEntity]
    func fetchSeasonalBanner() async throws -> SeasonalBannerEntity
}

public final class DefaultHomeUseCase: HomeUseCase {
    private let homeRepository: HomeRepository

    public init(homeRepository: HomeRepository) {
        self.homeRepository = homeRepository
    }

    public func fetchTimeCapsules(
        status: TimeCapsuleStatus?,
        page: Int,
        size: Int
    ) async throws -> TimeCapsulePageEntity {
        return try await homeRepository.fetchMyTimeCapsules(
            status: status,
            page: page,
            size: size
        )
    }

    public func fetchUnopenedTimeCapsules() async throws -> [TimeCapsuleEntity] {
        return try await homeRepository.fetchUnopenedTimeCapsules()
    }

    public func fetchSeasonalBanner() async throws -> SeasonalBannerEntity {
        return try await homeRepository.fetchSeasonalBanner()
    }
}
