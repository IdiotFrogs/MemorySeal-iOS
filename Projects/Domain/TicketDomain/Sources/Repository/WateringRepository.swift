import Foundation

public protocol WateringRepository {
    func fetchWaterings(capsuleId: Int, page: Int, size: Int, sort: WateringSort) async throws -> WateringEntity
    func water(capsuleId: Int) async throws
}
