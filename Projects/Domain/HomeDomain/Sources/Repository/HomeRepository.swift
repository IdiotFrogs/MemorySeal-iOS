import Foundation

import BaseDomain

public protocol HomeRepository {
    func fetchMyTimeCapsules(
        status: TimeCapsuleStatus?,
        page: Int,
        size: Int
    ) async throws -> TimeCapsulePageEntity
    func fetchUnopenedTimeCapsules() async throws -> [TimeCapsuleEntity]
    func fetchSeasonalBanner() async throws -> SeasonalBannerEntity
}
