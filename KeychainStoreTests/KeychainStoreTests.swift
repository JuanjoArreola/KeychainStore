//
//  KeychainStoreTests.swift
//  KeychainStoreTests
//
//  Created by Juan Jose Arreola on 8/13/15.
//  Copyright © 2015 juanjo. All rights reserved.
//

import XCTest
@testable import KeychainStore

class KeychainStoreTests: XCTestCase {
    
    var store: KeychainStore!
    
    override func setUp() {
        super.setUp()
        store = try! KeychainStore(account: "test")
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCreateDefaultStore() {
        let store = KeychainStore()
        XCTAssertNotNil(store)
    }
    
    func testSaveAndGetData() {
        do {
            let data = NSKeyedArchiver.archivedDataWithRootObject(["one", "two"])
            try store.setData(data, forKey: "array")
            
            let array = try store?.dataForKey("array")
            XCTAssertEqual(data, array)
        } catch {
            XCTFail("Error saving object")
        }
    }
    
    func testSaveAndGetString() {
        do {
            try store?.setString("lol", forKey: "string")
            
            let string = try store.stringForKey("string")
            XCTAssertEqual(string, "lol")
        } catch {
            XCTFail("Error saving object")
        }
    }
    
    func testSaveAndGetObject() {
        do {
            try store?.setObject(["object": true], forKey: "object")
            
            let object = try store.objectForKey("object") as! [String: Bool]
            XCTAssertEqual(object, ["object": true])
        } catch {
            XCTFail("Error saving object")
        }
    }
    
    func testUpdateObject() {
        do {
            try store.setObject(["1", "2"], forKey: "from2")
            
            try store.setObject(["2", "3"], forKey: "from2")
            
            let array = try store.objectForKey("from2") as! [String]
            XCTAssertEqual(array, ["2", "3"])
        } catch {
            XCTFail("Error saving object")
        }
    }
    
    func testDeleteObject() {
        do {
            try store.setObject(["to delete"], forKey: "delete")
            try store.deleteItemForKey("delete")
            let object = try store.objectForKey("delete")
            XCTAssertNil(object)
        } catch {
            XCTFail("Error deleting object")
        }
    }
    
    func testSaveAndGetDataWithAccessibility() {
        do {
            let data = NSKeyedArchiver.archivedDataWithRootObject(["passcode"])
            try store.setData(data, forKey: "whenPasscode", accessibility: KeychainAccessibility.WhenPasscodeSetThisDeviceOnly)
            
            let array = try store?.dataForKey("whenPasscode")
            XCTAssertEqual(data, array)
        } catch {
            XCTFail("Error saving object")
        }
    }
    
    func testUpdateNonexistentObject() {
        do {
            try store.updateObject(["nil"], forKey: "404")
            XCTFail()
        } catch KeychainStoreError.ItemNotFound {
        } catch {
            XCTFail()
        }
    }
    
}
