//
//  ObjectStoreTests.swift
//  KeychainStore
//
//  Created by Juan Jose Arreola on 3/12/16.
//  Copyright © 2016 juanjo. All rights reserved.
//

import XCTest
import KeychainStore

class ObjectStoreTests: XCTestCase {
    
    var store: KeychainStore<Card>!
    
    override func setUp() {
        super.setUp()
        
        self.store = KeychainStore<Card>(account: "test")
    }
    
    override func tearDown() {
        _ = try? self.store.deleteAllItems()
        
        super.tearDown()
    }
    
    func testSaveObject() {
        do {
            let card = Card(number: "4111111111111111", cardholder: "Me")
            try store.set(object: card, forKey: "test4")
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testGetObject() {
        do {
            let card = Card(number: "4111111111111111", cardholder: "Me")
            try store.set(object: card, forKey: "test")
            
            let result = try store.object(forKey: "test")
            XCTAssertNotNil(result)
        } catch {
            XCTFail()
        }
    }
    
    func testHasObject() {
        do {
            let card = Card(number: "4111111111111111", cardholder: "Me")
            try store.set(object: card, forKey: "test")
            
            let result = try store.hasKey("test")
            XCTAssertTrue(result)
        } catch {
            XCTFail()
        }
    }
    
    func testNotHasObject() {
        do {
            let result = try store.hasKey("test")
            XCTAssertFalse(result)
        } catch {
            XCTFail()
        }
    }
    
    func testUpdateObject() {
        do {
            let card = Card(number: "4111111111111111", cardholder: "Me")
            try store.set(object: card, forKey: "test")
            
            let updatedCard = Card(number: "4222222222222222", cardholder: "Me")
            try store.update(object: updatedCard, forKey: "test")
            
            let result = try store.object(forKey: "test")
            XCTAssertNotNil(result)
            XCTAssertEqual(result!.number, updatedCard.number)
        } catch {
            XCTFail()
        }
    }
    
    func testDeleteString() {
        do {
            let card = Card(number: "4111111111111111", cardholder: "Me")
            try store.set(object: card, forKey: "test")
            try store.deleteItem(forKey: "test")
            let result = try store.object(forKey: "test")
            XCTAssertNil(result)
        } catch {
            XCTFail()
        }
    }
    
    func testUpdateNonexistentString() {
        do {
            let updatedCard = Card(number: "4222222222222222", cardholder: "Me")
            try store.update(object: updatedCard, forKey: "test")
            XCTFail()
        } catch KeychainStoreError.itemNotFound {
        } catch {
            XCTFail()
        }
    }
    
    func testSaveAndGetStringWithAccessibility() {
        do {
            let card = Card(number: "4111111111111111", cardholder: "Me")
            try store.set(object: card, forKey: "test", accessibility: .whenPasscodeSetThisDeviceOnly)
            
            let result = try store.object(forKey: "test")
            XCTAssertNotNil(result)
        } catch {
            XCTFail("Error saving object")
        }
    }
    
    func testGetAllKeys() {
        do {
            let card = Card(number: "4111111111111111", cardholder: "Me")
            try store.set(object: card, forKey: "key1")
            try store.set(object: card, forKey: "key2")
            try store.set(object: card, forKey: "key3")
            
            try store.deleteItem(forKey: "key2")
            let keys = try store.allKeys()
            XCTAssertEqual(keys, ["key1", "key3"])
        } catch {
            XCTFail()
        }
    }
    
}


class Card: Codable {
    
    var number: String!
    var cardholder: String!
    
    required init(number: String, cardholder: String) {
        self.number = number
        self.cardholder = cardholder
    }
}
