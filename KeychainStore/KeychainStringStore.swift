//
//  KeychainStringStore.swift
//  KeychainStore
//
//  Created by Juan Jose Arreola on 03/04/17.
//  Copyright © 2017 juanjo. All rights reserved.
//

import Foundation

open class KeychainStringStore: AbstractKeychainStore {
    
    /// Retrieves a `String` from the keychain with the specified key
    /// - parameter key: The key of the `String` to be retrieved
    /// - returns: The `String` from the keychain
    open func string(forKey key: String) throws -> String? {
        if let data = try data(forKey: key) {
            return String(data: data, encoding: String.Encoding.utf8)
        }
        return nil
    }
    
    /// Adds a `String` to the keychain with the specified key
    /// - parameter string: The `String` to be stored
    /// - parameter key: The key of the item to be stored
    /// - parameter accessibility: The accessibility type of the string
    open func set(string: String, forKey key: String, accessibility: KeychainAccessibility = .whenUnlocked) throws {
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
