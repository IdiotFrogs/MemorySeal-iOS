import Foundation

public protocol WateringUseCase {
    func fetchWaterings(capsuleId: Int, page: Int, size: Int, sort: WateringSort) async throws -> WateringEntity
    func water(capsuleId: Int) async throws
}

public final class DefaultWateringUseCase: WateringUseCase {
    private let wateringRepository: WateringRepository

    public init(wateringRepository: WateringRepository) {
        self.wateringRepository = wateringRepository
    }

    public func fetchWaterings(
        capsuleId: Int,
        page: Int,
        size: Int,
        sort: WateringSort
    ) async throws -> WateringEntity {
        return try await wateringRepository.fetchWaterings(
            capsuleId: capsuleId,
            page: page,
            size: size,
            sort: sort
        )
    }

    public func water(capsuleId: Int) async throws {
        try await wateringRepository.water(capsuleId: capsuleId)
    }
}
