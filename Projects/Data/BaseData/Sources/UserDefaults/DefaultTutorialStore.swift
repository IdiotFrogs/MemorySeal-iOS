import Foundation

import BaseDomain

public final class DefaultTutorialStore: TutorialStore {

    private let userDefaultStorage: UserDefaultStorage

    public init(userDefaultStorage: UserDefaultStorage = DefaultUserDefaultStorage()) {
        self.userDefaultStorage = userDefaultStorage
    }

    public func isPending() -> Bool {
        return userDefaultStorage.get(forKey: .tutorialPending) as? Bool ?? false
    }

    public func markPending() {
        userDefaultStorage.set(value: true, forKey: .tutorialPending)
    }

    public func clearPending() {
        userDefaultStorage.remove(forKey: .tutorialPending)
    }
}
