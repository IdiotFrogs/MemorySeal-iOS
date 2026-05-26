import Foundation

import BaseDomain

public protocol HomeRepository {
    func fetchMyTimeCapsules() async throws -> [TimeCapsuleEntity]
}
