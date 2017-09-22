//
//  KeychainStoreError.swift
//  KeychainStore
//
//  Created by Juan Jose Arreola on 03/04/17.
//  Copyright © 2017 juanjo. All rights reserved.
//

import Foundation

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
