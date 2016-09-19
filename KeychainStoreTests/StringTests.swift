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
            try store.set(string: "test", forKey: "This is a test")
        } catch {
            XCTFail()
            print(error)
        }
    }
    
    func testGetString() {
        do {
            try store.set(string: "This is a Test", forKey: "test")
            
            let result = try store.string(forKey: "test")
            XCTAssertNotNil(result)
        } catch {
            XCTFail()
        }
    }
    
    func testUpdateString() {
        do {
            try store.set(string: "This is a Test", forKey: "test")
            try store.update(string: "Change test", forKey: "test")
            
            let result = try store.string(forKey: "test")
            XCTAssertNotNil(result)
            XCTAssertEqual(result!, "Change test")
        } catch {
            XCTFail()
        }
    }
    
    func testDeleteString() {
        do {
            try store.set(string: "This is a Test", forKey: "test")
            try store.deleteItem(forKey: "test")
            let result = try store.string(forKey: "test")
            XCTAssertNil(result)
        } catch {
            XCTFail()
        }
    }
    
    func testUpdateNonexistentString() {
        do {
            try store.update(string: "Updated string", forKey: "NotAKey")
            XCTFail()
        } catch KeychainStoreError.itemNotFound {
        } catch {
            XCTFail()
        }
    }
    
    func testSaveAndGetStringWithAccessibility() {
        do {
            try store.set(string: "whenPasscode", forKey: "test", accessibility: KeychainAccessibility.whenPasscodeSetThisDeviceOnly)
            
            let result = try store.string(forKey: "test")
            XCTAssertNotNil(result)
        } catch {
            XCTFail("Error saving object")
        }
    }
    
    func testGetAllKeys() {
        do {
            try store.set(string: "test 1", forKey: "key1")
            try store.set(string: "test 2", forKey: "key2")
            try store.set(string: "test 3", forKey: "key3")
            
            try store.deleteItem(forKey: "key2")
            let keys = try store.allKeys()
            XCTAssertEqual(keys, ["key1", "key3"])
        } catch {
            XCTFail()
        }
    }
    
}
