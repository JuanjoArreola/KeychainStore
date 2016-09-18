//
//  KeychainStore.swift
//  KeychainStore
//
//  Created by Juan Jose Arreola on 8/13/15.
//  Copyright © 2015 juanjo. All rights reserved.
//

import Foundation

private let secClass = kSecClass as String
private let secAttrGeneric = kSecAttrGeneric as String
private let secAttrService = kSecAttrService as String
private let secAttrAccessGroup = kSecAttrAccessGroup as String
private let secAttrAcount = kSecAttrAccount as String
private let secMatchLimit = kSecMatchLimit as String
private let secReturnData = kSecReturnData as String
private let secValueData = kSecValueData as String
private let secAttrAccessible = kSecAttrAccessible as String
private let secReturnAttributes = kSecReturnAttributes as String

public enum KeychainStoreError: Error {
    case invalidKey
    case invalidService
    case invalidAccessGroup
    case invalidAccount
    case invalidString
    case unexpectedError
    case unexpectedErrorCode(code: Int32)
    case itemNotFound
}

open class AbstractKeychainStore {
    
    open let account: String
    open private(set) var accessGroup: String?
    
    //    MARK: - Initialization
    
    public required init(account: String) throws {
        self.account = account
        if account.isEmpty {
            throw KeychainStoreError.invalidAccount
        }
    }
    
    public required init(account: String, accessGroup: String) throws {
        self.account = account
        self.accessGroup = accessGroup
        if account.isEmpty {
            throw KeychainStoreError.invalidAccount
        }
        if accessGroup.isEmpty {
            throw KeychainStoreError.invalidAccessGroup
        }
    }
    
    //    MARK: - create query
    
    func getQueryDictionary(forKey key: String) throws -> [String: AnyObject] {
        var queryDictionary: [String: AnyObject] = [secClass: kSecClassGenericPassword,
            secAttrAcount: account as AnyObject,
            secAttrService: key as AnyObject]
        if let accessGroup = accessGroup {
            queryDictionary[secAttrAccessGroup] = accessGroup as AnyObject?
        }
        return queryDictionary
    }
    
    //    MARK: - Get data
    /// Retrieves a `Data` object from the keychain with the specified key
    /// - Parameters:
    ///   - key: The key of the item to be retrieved
    /// - Returns: A `Data` object from the keychain
    open func data(forKey key: String) throws -> Data? {
        var query = try getQueryDictionary(forKey: key)
        
        query[secMatchLimit] = kSecMatchLimitOne
        query[secReturnData] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        if status == errSecSuccess {
            return result as? Data
        } else if status == errSecItemNotFound {
            return nil
        }
        throw error(fromStatus: status)
    }
    
    //    MARK: - Set data
    /// Adds a `Data` object to the keychain with the specified key
    /// - Parameters:
    ///   - data: The data to be stored
    ///   - key: The key of the item to be stored
    ///   - accessibility: The accessibility type of the data
    open func set(data: Data, forKey key: String, accessibility: KeychainAccessibility = KeychainAccessibility.whenUnlocked) throws {
        var query = try getQueryDictionary(forKey: key)
        query[secValueData] = data as AnyObject?
        query[secAttrAccessible] = accessibility.rawValue as AnyObject?
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            try self.update(data: data, forKey: key)
            return
        } else if status != errSecSuccess {
            throw error(fromStatus: status)
        }
    }
    
    //    MARK: - Update data
    /// Updates the data associated with the specified key
    /// - Parameters:
    ///   - data: The updated data
    ///   - key: The key of the item to be updated
    open func update(data: Data, forKey key: String) throws {
        let query = try getQueryDictionary(forKey: key)
        let updateQuery = [secValueData: data]
        
        let status = SecItemUpdate(query as CFDictionary, updateQuery as CFDictionary)
        if status != errSecSuccess {
            throw error(fromStatus: status)
        }
    }
    
    /// Returns a list of the keys of all the items saved for the store account
    /// - returns: A list of keys
    open func allKeys() throws -> [String] {
        var query: [String: AnyObject] = [secClass: kSecClassGenericPassword,
            secAttrAcount: account as AnyObject,
            secReturnAttributes: kCFBooleanTrue,
            secMatchLimit: kSecMatchLimitAll]
        if let accessGroup = accessGroup {
            query[secAttrAccessGroup] = accessGroup as AnyObject?
        }
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        if status == errSecSuccess {
            var keys = [String]()
            if let items = result as? [[String: AnyObject]] {
                for item in items {
                    if let key = item[secAttrService] as? String {
                        keys.append(key)
                    }
                }
            }
            return keys
        }
        else if status == errSecItemNotFound {
            return []
        }
        throw error(fromStatus: status)
    }
    
    //    MARK: - Delete
    /// Remove item with a specified key.
    /// - parameter key: The key of the item to be removed
    open func deleteItem(forKey key: String) throws {
        let query = try getQueryDictionary(forKey: key)
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            throw KeychainStoreError.unexpectedErrorCode(code: status)
        }
    }
    
    //    MARK: - Delete all
    /// Remove all the items for the store account
    open func deleteAllItems() throws {
        let keys = try allKeys()
        for key in keys {
            do {
                try deleteItem(forKey: key)
            } catch {}
        }
    }
    
}

open class KeychainStringStore: AbstractKeychainStore {
    
    /// Retrieves a `String` from the keychain with the specified key
    /// - parameter key: The key of the `String` to be retrieved
    /// - returns: The `String` from the keychain
    open func string(forKey key: String) throws -> String? {
        if let data = try data(forKey: key) {
            return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String
        }
        return nil
    }
    
    /// Adds a `String` to the keychain with the specified key
    /// - parameter string: The `String` to be stored
    /// - parameter key: The key of the item to be stored
    /// - parameter accessibility: The accessibility type of the string
    open func set(string: String, forKey key: String, accessibility: KeychainAccessibility = KeychainAccessibility.whenUnlocked) throws {
        if let data = string.data(using: String.Encoding.utf8) {
            try set(data: data, forKey: key, accessibility: accessibility)
        } else {
            throw KeychainStoreError.invalidString
        }
    }
    
    //    MARK: - Update string
    /// Updates the string associated with the specified key
    /// - parameter string: The `String` object
    /// - parameter key: The key of the `String` to be updated
    open func update(string: String, forKey key: String) throws {
        if let data = string.data(using: String.Encoding.utf8) {
            try update(data: data, forKey: key)
        } else {
            throw KeychainStoreError.invalidString
        }
    }
}

open class KeychainStore<T: NSCoding>: AbstractKeychainStore {
    
    public required init(account: String) throws {
        try super.init(account: account)
    }
    
    public required init(account: String, accessGroup: String) throws {
        try super.init(account: account, accessGroup: accessGroup)
    }
  
//    MARK: - Get object
    /// Retrieves an object from the keychain with the specified key
    /// - parameter key: The key of the item to be retrieved
    /// - returns: The object from the keychain
    open func object(forKey key: String) throws -> T? {
        if let data = try data(forKey: key) {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? T
        }
        return nil
    }
    
//    MARK: - Set object
    /// Adds an object to the keychain with the specified key
    /// - parameter object: The object to be stored
    /// - parameter key: The key of the item to be stored
    /// - parameter accessibility: The accessibility type of the object
    open func set(object: T, forKey key: String, accessibility: KeychainAccessibility = KeychainAccessibility.whenUnlocked) throws {
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        try set(data: data, forKey: key, accessibility: accessibility)
    }
    
//    MARK: - Update object
    /// Updates the object associated with the specified key
    /// - parameter object: The updated object
    /// - parameter key: The key of the object to be updated
    open func update(object: T, forKey key: String) throws {
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        try update(data: data, forKey: key)
    }
    
}

private func error(fromStatus staus: OSStatus) -> KeychainStoreError {
    switch staus {
    case errSecItemNotFound:
        return KeychainStoreError.itemNotFound
    default:
        return KeychainStoreError.unexpectedErrorCode(code: staus)
    }
}

// MARK: - KeychainAccessibility

public enum KeychainAccessibility: RawRepresentable {
    case afterFirstUnlock, afterFirstUnlockThisDeviceOnly, always, whenPasscodeSetThisDeviceOnly, alwaysThisDeviceOnly, whenUnlocked, whenUnlockedThisDeviceOnly
    
    public init?(rawValue: String) {
        return nil
    }
    
    public var rawValue: String {
        switch self {
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock as String
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
        case .always:
            return kSecAttrAccessibleAlways as String
        case .whenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly as String
        case .alwaysThisDeviceOnly:
            return kSecAttrAccessibleAlwaysThisDeviceOnly as String
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked as String
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
        }
    }

}

