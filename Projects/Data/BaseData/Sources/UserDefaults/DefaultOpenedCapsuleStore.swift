import Foundation

import BaseDomain

public final class DefaultOpenedCapsuleStore: OpenedCapsuleStore {

    private let userDefaults: UserDefaults
    private let userDefaultStorage: UserDefaultStorage

    public init(
        userDefaults: UserDefaults = .standard,
        userDefaultStorage: UserDefaultStorage = DefaultUserDefaultStorage()
    ) {
        self.userDefaults = userDefaults
        self.userDefaultStorage = userDefaultStorage
    }

    public func isOpened(capsuleId: Int) -> Bool {
        guard let userId = fetchCurrentUserId() else { return false }
        return openedCapsuleIds(userId: userId).contains(capsuleId)
    }

    public func markOpened(capsuleId: Int) {
        guard let userId = fetchCurrentUserId() else { return }
        var ids = openedCapsuleIds(userId: userId)
        ids.insert(capsuleId)
        userDefaults.set(Array(ids), forKey: storageKey(userId: userId))
    }

    private func fetchCurrentUserId() -> Int? {
        return userDefaultStorage.get(forKey: .userId) as? Int
    }

    private func openedCapsuleIds(userId: Int) -> Set<Int> {
        let stored = userDefaults.array(forKey: storageKey(userId: userId)) as? [Int] ?? []
        return Set(stored)
    }

    private func storageKey(userId: Int) -> String {
        return "opened_capsules_\(userId)"
    }
}
