//
//  AbstractKeychainStore.swift
//  KeychainStore
//
//  Created by Juan Jose Arreola on 03/04/17.
//  Copyright © 2017 juanjo. All rights reserved.
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
    
    func getQueryDictionary(forKey key: String) throws -> [String: Any] {
        var queryDictionary: [String: Any] = [
            secClass: kSecClassGenericPassword,
            secAttrAcount: account,
            secAttrService: key]
        if let accessGroup = accessGroup {
            queryDictionary[secAttrAccessGroup] = accessGroup
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
    open func set(data: Data, forKey key: String, accessibility: KeychainAccessibility = .whenUnlocked) throws {
        var query = try getQueryDictionary(forKey: key)
        query[secValueData] = data
        query[secAttrAccessible] = accessibility.rawValue
        
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
        var query: [String: Any] = [
            secClass: kSecClassGenericPassword,
            secAttrAcount: account,
            secReturnAttributes: kCFBooleanTrue,
            secMatchLimit: kSecMatchLimitAll]
        if let accessGroup = accessGroup {
            query[secAttrAccessGroup] = accessGroup
        }
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        if status == errSecSuccess {
            guard let items = result as? [[String: Any]] else {
                return []
            }
            return items.flatMap({ $0[secAttrService] as? String })
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
            try deleteItem(forKey: key)
        }
    }
    
}

internal func error(fromStatus staus: OSStatus) -> KeychainStoreError {
    switch staus {
    case errSecItemNotFound:
        return KeychainStoreError.itemNotFound
    default:
        return KeychainStoreError.unexpectedErrorCode(code: staus)
    }
}
