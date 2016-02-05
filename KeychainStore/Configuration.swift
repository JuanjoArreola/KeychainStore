//
//  Configuration.swift
//  KeychainStore
//
//  Created by Juan Jose Arreola Simon on 8/24/15.
//  Copyright © 2015 juanjo. All rights reserved.
//

import Foundation

public final class Configuration {
    
    private static let defaultProperties: [String: AnyObject] = {
        let bundle = NSBundle(forClass: Configuration.self)
        let path = bundle.pathForResource("keychain_properties", ofType: "plist")
        return NSDictionary(contentsOfFile: path!) as! [String:AnyObject]
        }()
    
    private static let properties: [String: AnyObject]? = {
        if let path = NSBundle.mainBundle().pathForResource("KeychainStoreProperties", ofType: "plist") {
            return NSDictionary(contentsOfFile: path) as? [String: AnyObject]
        }
        return nil
    }()
    
    static var defaultAccountName: String = {
        return properties?["default_account_name"] as? String ?? defaultProperties["default_account_name"] as! String
    }()
}