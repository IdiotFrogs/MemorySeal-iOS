import Foundation

import BaseDomain

public protocol HomeUseCase {
    func fetchMyTimeCapsules(role: TimeCapsuleRole) async throws -> [TimeCapsuleEntity]
}

public final class DefaultHomeUseCase: HomeUseCase {
    private let homeRepository: HomeRepository

    public init(homeRepository: HomeRepository) {
        self.homeRepository = homeRepository
    }

    public func fetchMyTimeCapsules(role: TimeCapsuleRole) async throws -> [TimeCapsuleEntity] {
        let allCapsules = try await homeRepository.fetchMyTimeCapsules()

        return allCapsules.filter { capsule in
            capsule.timeCapsuleStatus != .opened && capsule.role == role
        }
    }
}
