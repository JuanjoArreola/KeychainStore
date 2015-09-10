//
//  KeychainStore.swift
//  KeychainStore
//
//  Created by Juan Jose Arreola on 8/13/15.
//  Copyright © 2015 juanjo. All rights reserved.
//

import Foundation

let secClass = kSecClass as String
let secAttrGeneric = kSecAttrGeneric as String
let secAttrService = kSecAttrService as String
let secAttrAccessGroup = kSecAttrAccessGroup as String
let secAttrAcount = kSecAttrAccount as String
let secMatchLimit = kSecMatchLimit as String
let secReturnData = kSecReturnData as String
let secValueData = kSecValueData as String
let secAttrAccessible = kSecAttrAccessible as String
let secReturnAttributes = kSecReturnAttributes as String

public enum KeychainStoreError: ErrorType {
    case InvalidKey
    case InvalidService
    case InvalidAccessGroup
    case InvalidAccount
    case InvalidString
    case UnexpectedError
    case UnexpectedErrorCode(code: Int32)
    case ItemNotFound
}

public class KeychainStore: NSObject {
    
    public let account: String!
    private(set) var accessGroup: String?
    
    private static var defaultStore: KeychainStore = {
        return KeychainStore()
    }()
    
//    MARK: - Initialization
    
    public override init() {
        self.account = Configuration.defaultAccountName
    }
    
    public init(account: String) throws {
        self.account = account
        super.init()
        
        if account.isEmpty {
            throw KeychainStoreError.InvalidAccount
        }
    }
    
    public convenience init(account: String, accessGroup: String) throws {
        try self.init(account: account)
        if accessGroup.isEmpty {
            throw KeychainStoreError.InvalidAccessGroup
        }
        self.accessGroup = accessGroup
    }
    
//    MARK: - Default store
    
    public class func dataForKey(key: String) throws -> NSData? {
        return try defaultStore.dataForKey(key)
    }
    
    public class func objectForKey(key: String) throws -> AnyObject? {
        return try defaultStore.objectForKey(key)
    }
    
    public class func stringForKey(key: String) throws -> String? {
        return try defaultStore.stringForKey(key)
    }
    
    public class func setData(data: NSData, forKey key: String, accessibility: KeychainAccessibility = .WhenUnlocked) throws {
        try defaultStore.setData(data, forKey: key, accessibility: accessibility)
    }
    
    public class func setString(string: String, forKey key: String, accessibility: KeychainAccessibility = .WhenUnlocked) throws {
        try defaultStore.setString(string, forKey: key, accessibility: accessibility)
    }
    
    public class func setObject(object: NSCoding, forKey key: String, accessibility: KeychainAccessibility = .WhenUnlocked) throws {
        try defaultStore.setObject(object, forKey: key, accessibility: accessibility)
    }
    
    public class func deleteItemForKey(key: String) throws {
        try defaultStore.deleteItemForKey(key)
    }
    
    public class func updateData(data: NSData, forKey key: String) throws {
        try defaultStore.updateData(data, forKey: key)
    }
    
//    MARK: - create query
    
    private func getQueryDictionaryForKey(key: String) throws -> [String: AnyObject] {
        var queryDictionary: [String: AnyObject] = [secClass: kSecClassGenericPassword,
                                                    secAttrAcount: account,
                                                    secAttrService: key]
        if let accessGroup = accessGroup {
            queryDictionary[secAttrAccessGroup] = accessGroup
        }
        
        return queryDictionary
    }
    
//    MARK: - Get data
    /// Retrieves a `NSData` from the keychain with the specified key
    /// - parameter key: The key of the item to be retrieved
    /// - returns: The `NSData` from the keychain
    public func dataForKey(key: String) throws -> NSData? {
        var query = try getQueryDictionaryForKey(key)
        
        query[secMatchLimit] = kSecMatchLimitOne
        query[secReturnData] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) {
            SecItemCopyMatching(query, UnsafeMutablePointer($0))
        }
        if status == errSecSuccess {
            return result as? NSData
        } else if status == errSecItemNotFound {
            return nil
        }
        throw errorFromStatus(status)
    }
  
//    MARK: - Get object
    /// Retrieves an object from the keychain with the specified key
    /// - parameter key: The key of the item to be retrieved
    /// - returns: The object from the keychain
    public func objectForKey(key: String) throws -> AnyObject? {
        if let data = try dataForKey(key) {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data)
        }
        return nil
    }
    
//    MARK: - Get String
    /// Retrieves a `String` from the keychain with the specified key
    /// - parameter key: The key of the `String` to be retrieved
    /// - returns: The `String` from the keychain
    public func stringForKey(key: String) throws -> String? {
        if let data = try dataForKey(key) {
            return NSString(data: data, encoding: NSUTF8StringEncoding) as? String
        }
        return nil
    }
    
    /// Returns a list of the keys of all the items saved for the store account
    /// - returns: A list of keys
    public func allKeys() throws -> [String] {
        var query: [String: AnyObject] = [secClass: kSecClassGenericPassword,
            secAttrAcount: account,
            secReturnAttributes: kCFBooleanTrue,
            secMatchLimit: kSecMatchLimitAll]
        if let accessGroup = accessGroup {
            query[secAttrAccessGroup] = accessGroup
        }
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) {
            SecItemCopyMatching(query, UnsafeMutablePointer($0))
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
        throw errorFromStatus(status)
    }
    
//    MARK: - Set data
    /// Adds a `NSData` object to the keychain with the specified key
    /// - parameter data: The data to be stored
    /// - parameter key: The key of the item to be stored
    /// - parameter accessibility: The accessibility type of the data
    public func setData(data: NSData, forKey key: String, accessibility: KeychainAccessibility = .WhenUnlocked) throws {
        var query = try getQueryDictionaryForKey(key)
        query[secValueData] = data
        query[secAttrAccessible] = accessibility.rawValue
        
        let status = SecItemAdd(query, nil)
        if status == errSecDuplicateItem {
            try self.updateData(data, forKey: key)
            return
        } else if status != errSecSuccess {
            throw errorFromStatus(status)
        }
    }
    
//    MARK: - Set string
    /// Adds a `String` to the keychain with the specified key
    /// - parameter string: The `String` to be stored
    /// - parameter key: The key of the item to be stored
    /// - parameter accessibility: The accessibility type of the string
    public func setString(string: String, forKey key: String, accessibility: KeychainAccessibility = .WhenUnlocked) throws {
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            try setData(data, forKey: key, accessibility: accessibility)
        } else {
            throw KeychainStoreError.InvalidString
        }
    }
    
//    MARK: - Set object
    /// Adds an object to the keychain with the specified key
    /// - parameter object: The object to be stored
    /// - parameter key: The key of the item to be stored
    /// - parameter accessibility: The accessibility type of the object
    public func setObject(object: NSCoding, forKey key: String, accessibility: KeychainAccessibility = .WhenUnlocked) throws {
        let data = NSKeyedArchiver.archivedDataWithRootObject(object)
        try setData(data, forKey: key, accessibility: accessibility)
    }
    
//    MARK: - Delete
    /// Remove item with a specified key.
    /// - parameter key: The key of the item to be removed
    public func deleteItemForKey(key: String) throws {
        let query = try getQueryDictionaryForKey(key)
        let status = SecItemDelete(query)
        if status != errSecSuccess {
            throw KeychainStoreError.UnexpectedErrorCode(code: status)
        }
    }
    
//    MARK: - Delete all
    /// Remove all the items for the store account
    public func deleteAllItems() throws {
        let keys = try allKeys()
        for key in keys {
            do {
                try deleteItemForKey(key)
            } catch {}
        }
    }
    
//    MARK: - Update data
    /// Updates the data associated with the specified key
    /// - parameter data: The updated data
    /// - parameter key: The key of the item to be updated
    public func updateData(data: NSData, forKey key: String) throws {
        let query = try getQueryDictionaryForKey(key)
        let updateQuery = [secValueData: data]
            
        let status = SecItemUpdate(query, updateQuery)
        if status != errSecSuccess {
            throw errorFromStatus(status)
        }
    }
    
//    MARK: - Update object
    /// Updates the object associated with the specified key
    /// - parameter object: The updated object
    /// - parameter key: The key of the object to be updated
    public func updateObject(object: AnyObject, forKey key: String) throws {
        let data = NSKeyedArchiver.archivedDataWithRootObject(object)
        try updateData(data, forKey: key)
    }
    
//    MARK: - Update string
    /// Updates the string associated with the specified key
    /// - parameter string: The `String` object
    /// - parameter key: The key of the `String` to be updated
    public func updateString(string: String, forKey key: String) throws {
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            try updateData(data, forKey: key)
        } else {
            throw KeychainStoreError.InvalidString
        }
    }
    
}

func errorFromStatus(staus: OSStatus) -> KeychainStoreError {
    switch staus {
    case errSecItemNotFound:
        return KeychainStoreError.ItemNotFound
    default:
        return KeychainStoreError.UnexpectedErrorCode(code: staus)
    }
}

// MARK: - KeychainAccessibility

public enum KeychainAccessibility: RawRepresentable {
    case AfterFirstUnlock, AfterFirstUnlockThisDeviceOnly, Always, WhenPasscodeSetThisDeviceOnly, AlwaysThisDeviceOnly,
    WhenUnlocked, WhenUnlockedThisDeviceOnly
    
    public init?(rawValue: String) {
        return nil
    }
    
    public var rawValue: String {
        switch self {
        case AfterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock as String
        case AfterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
        case Always:
            return kSecAttrAccessibleAlways as String
        case WhenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly as String
        case AlwaysThisDeviceOnly:
            return kSecAttrAccessibleAlwaysThisDeviceOnly as String
        case WhenUnlocked:
            return kSecAttrAccessibleWhenUnlocked as String
        case WhenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
        }
    }

}

