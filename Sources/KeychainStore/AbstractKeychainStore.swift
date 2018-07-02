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
    
    public let account: String
    public private(set) var accessGroup: String?
    
    //    MARK: - Initialization
    
    public required init(account: String, accessGroup: String? = nil){
        self.account = account
        self.accessGroup = accessGroup
    }
    
    //    MARK: - create query
    
    func keychainQuery(forKey key: String) throws -> [String: Any] {
        var query: [String: Any] = [
            secClass: kSecClassGenericPassword,
            secAttrAcount: account,
            secAttrService: key]
        if let accessGroup = accessGroup {
            query[secAttrAccessGroup] = accessGroup
        }
        return query
    }
    
    //    MARK: - Get data
    /// Retrieves a `Data` object from the keychain with the specified key
    /// - Parameters:
    ///   - key: The key of the item to be retrieved
    /// - Returns: A `Data` object from the keychain
    open func data(forKey key: String) throws -> Data? {
        var query = try keychainQuery(forKey: key)
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
        throw error(from: status)
    }
    
    //    MARK: - Set data
    /// Adds a `Data` object to the keychain with the specified key
    /// - Parameters:
    ///   - data: The data to be stored
    ///   - key: The key of the item to be stored
    ///   - accessibility: The accessibility type of the data
    open func set(data: Data, forKey key: String, accessibility: KeychainAccessibility = .whenUnlocked) throws {
        var query = try keychainQuery(forKey: key)
        query[secValueData] = data
        query[secAttrAccessible] = accessibility.rawValue
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            try self.update(data: data, forKey: key)
            return
        } else if status != errSecSuccess {
            throw error(from: status)
        }
    }
    
    //    MARK: - Update data
    /// Updates the data associated with the specified key
    /// - Parameters:
    ///   - data: The updated data
    ///   - key: The key of the item to be updated
    open func update(data: Data, forKey key: String) throws {
        let query = try keychainQuery(forKey: key)
        let updateQuery = [secValueData: data]
        
        let status = SecItemUpdate(query as CFDictionary, updateQuery as CFDictionary)
        if status != errSecSuccess {
            throw error(from: status)
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
            return items.compactMap({ $0[secAttrService] as? String })
        }
        else if status == errSecItemNotFound {
            return []
        }
        throw error(from: status)
    }
    
    //    MARK: - Delete
    /// Remove item with a specified key.
    /// - parameter key: The key of the item to be removed
    open func deleteItem(forKey key: String) throws {
        let query = try keychainQuery(forKey: key)
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            throw error(from: status)
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

func error(from staus: OSStatus) -> KeychainStoreError {
    switch staus {
    case errSecItemNotFound:
        return KeychainStoreError.itemNotFound
    default:
        return KeychainStoreError.unexpectedErrorCode(code: staus)
    }
}
