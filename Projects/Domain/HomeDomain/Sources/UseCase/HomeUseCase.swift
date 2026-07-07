import Foundation

import BaseDomain

public protocol HomeUseCase {
    func fetchMyTimeCapsules(role: TimeCapsuleRole) async throws -> [TimeCapsuleEntity]
    func fetchOpenedTimeCapsules() async throws -> [TimeCapsuleEntity]
}

public final class DefaultHomeUseCase: HomeUseCase {
    private let homeRepository: HomeRepository
    private let openedCapsuleStore: OpenedCapsuleStore

    public init(homeRepository: HomeRepository, openedCapsuleStore: OpenedCapsuleStore) {
        self.homeRepository = homeRepository
        self.openedCapsuleStore = openedCapsuleStore
    }

    public func fetchMyTimeCapsules(role: TimeCapsuleRole) async throws -> [TimeCapsuleEntity] {
        let allCapsules = try await homeRepository.fetchMyTimeCapsules()

        return allCapsules.filter { capsule in
            let notOpenedOrUnread = capsule.timeCapsuleStatus != .opened
                || (capsule.timeCapsuleStatus == .opened && !openedCapsuleStore.isOpened(capsuleId: capsule.timeCapsuleId))
            return notOpenedOrUnread && capsule.role == role
        }
    }

    public func fetchOpenedTimeCapsules() async throws -> [TimeCapsuleEntity] {
        let allCapsules = try await homeRepository.fetchMyTimeCapsules()

        return allCapsules.filter { capsule in
            capsule.timeCapsuleStatus == .opened
        }
    }
}
