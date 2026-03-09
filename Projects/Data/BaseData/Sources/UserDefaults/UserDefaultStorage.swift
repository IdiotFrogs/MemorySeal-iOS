//
//  UserDefaultStorage.swift
//  BaseData
//
//  Created by 선민재 on 2/27/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public enum UserDefaultsKeys: String {
    case userId
}

public protocol UserDefaultStorage {
    func set(value: Any, forKey: UserDefaultsKeys)
    func get(forKey: UserDefaultsKeys) -> Any?
    func remove(forKey: UserDefaultsKeys)
}

public final class DefaultUserDefaultStorage: UserDefaultStorage {

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func set(value: Any, forKey key: UserDefaultsKeys) {
        userDefaults.set(value, forKey: key.rawValue)
    }

    public func get(forKey key: UserDefaultsKeys) -> Any? {
        return userDefaults.object(forKey: key.rawValue)
    }

    public func remove(forKey key: UserDefaultsKeys) {
        userDefaults.removeObject(forKey: key.rawValue)
    }
}
