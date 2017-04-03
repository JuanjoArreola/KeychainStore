//
//  KeychainStore.swift
//  KeychainStore
//
//  Created by Juan Jose Arreola on 8/13/15.
//  Copyright © 2015 juanjo. All rights reserved.
//

import Foundation

open class KeychainStore<T: NSCoding>: AbstractKeychainStore {
  
    /// Retrieves an object from the keychain with the specified key
    /// - parameter key: The key of the item to be retrieved
    /// - returns: The object from the keychain
    open func object(forKey key: String) throws -> T? {
        if let data = try data(forKey: key) {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? T
        }
        return nil
    }
    
    /// Adds an object to the keychain with the specified key
    /// - parameter object: The object to be stored
    /// - parameter key: The key of the item to be stored
    /// - parameter accessibility: The accessibility type of the object
    open func set(object: T, forKey key: String, accessibility: KeychainAccessibility = .whenUnlocked) throws {
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        try set(data: data, forKey: key, accessibility: accessibility)
    }
    
    /// Updates the object associated with the specified key
    /// - parameter object: The updated object
    /// - parameter key: The key of the object to be updated
    open func update(object: T, forKey key: String) throws {
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        try update(data: data, forKey: key)
    }
    
}
