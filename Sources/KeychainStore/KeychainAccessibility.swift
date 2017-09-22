//
//  KeychainAccessibility.swift
//  KeychainStore
//
//  Created by Juan Jose Arreola on 03/04/17.
//  Copyright © 2017 juanjo. All rights reserved.
//

import Foundation

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
