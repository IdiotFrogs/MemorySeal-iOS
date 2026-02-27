//
//  KeyChainStorage.swift
//  BaseData
//
//  Created by 선민재 on 2/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public enum KeyChainKeys: String {
    case accessToken
    case refreshToken
}

public protocol KeyChainStorage {
    func add(value: String, forKey: KeyChainKeys)
    func read(forKey: KeyChainKeys) -> String?
    func update(_ value: String, forKey: KeyChainKeys)
    func delete(key: KeyChainKeys) -> Bool
}

public final class DefaultKeyChainStorage: KeyChainStorage {
    
    public init() {}
    
    public func add(value: String, forKey: KeyChainKeys) {
        guard let data: Data = value.data(using: .utf8) else { return }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: forKey.rawValue,
            kSecValueData: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            update(value, forKey: forKey)
        }
    }
    
    public func read(forKey: KeyChainKeys) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: forKey.rawValue,
            kSecReturnAttributes: true,
            kSecReturnData: true
        ]
            
        var item: CFTypeRef?
                    
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let existingItem = item as? [String: Any],
              let data = existingItem["v_Data"] as? Data,
              let value = String(data: data, encoding: .utf8) else { return nil }
            
        return value
    }
    
    public func update(_ value: String, forKey: KeyChainKeys) {
        let previousQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: forKey.rawValue
        ]

        guard let data = value.data(using: .utf8) else { return }

        let updateQuery: [CFString: Any] = [kSecValueData: data]

        let status = SecItemUpdate(previousQuery as CFDictionary, updateQuery as CFDictionary)

        if status == errSecItemNotFound {
            add(value: value, forKey: forKey)
        }
    }
    
    
    public func delete(key: KeyChainKeys) -> Bool {
        let deleteQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue
        ]
        
        let status = SecItemDelete(deleteQuery as CFDictionary)
        
        return status == errSecSuccess
    }
}
