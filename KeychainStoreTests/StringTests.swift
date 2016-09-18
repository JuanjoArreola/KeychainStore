//
//  StringTests.swift
//  KeychainStore
//
//  Created by Juan Jose Arreola on 3/12/16.
//  Copyright © 2016 juanjo. All rights reserved.
//

import XCTest
import KeychainStore

class StringTests: XCTestCase {
    
    var store: KeychainStringStore!
    
    override func setUp() {
        super.setUp()
        
        self.store = try! KeychainStringStore(account: "test")
    }
    
    override func tearDown() {
        _ = try? self.store.deleteAllItems()
        
        super.tearDown()
    }
    
    func testSaveString() {
        do {
            try store.setString("test", forKey: "This is a test")
        } catch {
            XCTFail()
        }
    }
    
    func testGetString() {
        do {
            try store.setString("This is a Test", forKey: "test")
            
            let result = try store.stringForKey("test")
            XCTAssertNotNil(result)
        } catch {
            XCTFail()
        }
    }
    
    func testUpdateString() {
        do {
            try store.setString("This is a Test", forKey: "test")
            try store.updateString("Change test", forKey: "test")
            
            let result = try store.stringForKey("test")
            XCTAssertNotNil(result)
            XCTAssertEqual(result!, "Change test")
        } catch {
            XCTFail()
        }
    }
    
    func testDeleteString() {
        do {
            try store.setString("This is a Test", forKey: "test")
            try store.deleteItemForKey("test")
            let result = try store.stringForKey("test")
            XCTAssertNil(result)
        } catch {
            XCTFail()
        }
    }
    
    func testUpdateNonexistentString() {
        do {
            try store.updateString("Updated string", forKey: "NotAKey")
            XCTFail()
        } catch KeychainStoreError.itemNotFound {
        } catch {
            XCTFail()
        }
    }
    
    func testSaveAndGetStringWithAccessibility() {
        do {
            try store.setString("whenPasscode", forKey: "test", accessibility: KeychainAccessibility.whenPasscodeSetThisDeviceOnly)
            
            let result = try store.stringForKey("test")
            XCTAssertNotNil(result)
        } catch {
            XCTFail("Error saving object")
        }
    }
    
    func testGetAllKeys() {
        do {
            try store.setString("test 1", forKey: "key1")
            try store.setString("test 2", forKey: "key2")
            try store.setString("test 3", forKey: "key3")
            
            try store.deleteItemForKey("key2")
            let keys = try store.allKeys()
            XCTAssertEqual(keys, ["key1", "key3"])
        } catch {
            XCTFail()
        }
    }
    
}
