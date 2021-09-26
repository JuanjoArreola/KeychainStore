//
//  KeychainStore.swift
//  KeychainStore
//
//  Created by Juan Jose Arreola on 8/13/15.
//  Copyright © 2015 juanjo. All rights reserved.
//

import Foundation

public final class KeychainStore<T: Codable>: AbstractKeychainStore {
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
  
    /// Retrieves an instance from the keychain with the specified key
    /// - parameter key: The key of the item to be retrieved
    /// - returns: The instance from the keychain
    public func instance(forKey key: String) throws -> T? {
        guard let data = try data(forKey: key) else { return nil }
        return try decoder.decode(T.self, from: data)
    }
    
    /// Adds an instance to the keychain with the specified key
    /// - parameter instance: The object to be stored
    /// - parameter key: The key of the item to be stored
    /// - parameter accessibility: The accessibility type of the object
    public func set(_ instance: T, forKey key: String, accessibility: KeychainAccessibility = .whenUnlocked) throws {
        let data = try encoder.encode(instance)
        try set(data: data, forKey: key, accessibility: accessibility)
    }
    
    /// Updates the instance associated with the specified key
    /// - parameter instance: The updated object
    /// - parameter key: The key of the object to be updated
    public func update(_ instance: T, forKey key: String) throws {
        let data = try encoder.encode(instance)
        try update(data: data, forKey: key)
    }
    
}
