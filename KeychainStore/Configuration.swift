//
//  Configuration.swift
//  KeychainStore
//
//  Created by Juan Jose Arreola Simon on 8/24/15.
//  Copyright © 2015 juanjo. All rights reserved.
//

import Foundation

public final class Configuration {
    
    private static let defaultProperties: [String: Any] = {
        let bundle = Bundle(for: Configuration.self)
        let path = bundle.path(forResource: "keychain_properties", ofType: "plist")
        return NSDictionary(contentsOfFile: path!) as! [String: Any]
    }()
    
    private static let properties: [String: Any]? = {
        if let path = Bundle.main.path(forResource: "KeychainStoreProperties", ofType: "plist") {
            return NSDictionary(contentsOfFile: path) as? [String: Any]
        }
        return nil
    }()
    
    static var defaultAccountName: String = {
        return properties?["default_account_name"] as? String ?? defaultProperties["default_account_name"] as! String
    }()
}
