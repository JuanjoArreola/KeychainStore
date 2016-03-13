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
        
        self.store = try! KeychainStore<Card>(account: "test")
    }
    
    override func tearDown() {
        _ = try? self.store.deleteAllItems()
        
        super.tearDown()
    }
    
    func testSaveObject() {
        do {
            let card = Card(number: "4111111111111111", cardholder: "Me")
            try store.setObject(card, forKey: "test")
        } catch {
            XCTFail()
        }
    }
    
    func testGetObject() {
        do {
            let card = Card(number: "4111111111111111", cardholder: "Me")
            try store.setObject(card, forKey: "test")
            
            let result = try store.objectForKey("test")
            XCTAssertNotNil(result)
        } catch {
            XCTFail()
        }
    }
    
    func testUpdateObject() {
        do {
            let card = Card(number: "4111111111111111", cardholder: "Me")
            try store.setObject(card, forKey: "test")
            
            let updatedCard = Card(number: "4222222222222222", cardholder: "Me")
            try store.updateObject(updatedCard, forKey: "test")
            
            let result = try store.objectForKey("test")
            XCTAssertNotNil(result)
            XCTAssertEqual(result!.number, updatedCard.number)
        } catch {
            XCTFail()
        }
    }
    
    func testDeleteString() {
        do {
            let card = Card(number: "4111111111111111", cardholder: "Me")
            try store.setObject(card, forKey: "test")
            try store.deleteItemForKey("test")
            let result = try store.objectForKey("test")
            XCTAssertNil(result)
        } catch {
            XCTFail()
        }
    }
    
    func testUpdateNonexistentString() {
        do {
            let updatedCard = Card(number: "4222222222222222", cardholder: "Me")
            try store.updateObject(updatedCard, forKey: "test")
            XCTFail()
        } catch KeychainStoreError.ItemNotFound {
        } catch {
            XCTFail()
        }
    }
    
    func testSaveAndGetStringWithAccessibility() {
        do {
            let card = Card(number: "4111111111111111", cardholder: "Me")
            try store.setObject(card, forKey: "test", accessibility: KeychainAccessibility.WhenPasscodeSetThisDeviceOnly)
            
            let result = try store.objectForKey("test")
            XCTAssertNotNil(result)
        } catch {
            XCTFail("Error saving object")
        }
    }
    
    func testGetAllKeys() {
        do {
            let card = Card(number: "4111111111111111", cardholder: "Me")
            try store.setObject(card, forKey: "key1")
            try store.setObject(card, forKey: "key2")
            try store.setObject(card, forKey: "key3")
            
            try store.deleteItemForKey("key2")
            let keys = try store.allKeys()
            XCTAssertEqual(keys, ["key1", "key3"])
        } catch {
            XCTFail()
        }
    }
    
}


class Card: NSObject, NSCoding {
    
    var number: String!
    var cardholder: String!
    
    required init(number: String, cardholder: String) {
        self.number = number
        self.cardholder = cardholder
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let number = aDecoder.decodeObjectForKey("number") as? String else { return nil }
        guard let cardholder = aDecoder.decodeObjectForKey("cardholder") as? String else { return nil }
        self.init(number: number, cardholder: cardholder)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(number, forKey: "number")
        aCoder.encodeObject(cardholder, forKey: "cardholder")
    }
}