# KeychainStore
Swift 3 Framework to access the Keychain

![Cocoapods](https://img.shields.io/cocoapods/v/KeychainStore.svg)
![Platform](https://img.shields.io/cocoapods/p/KeychainStore.svg)
![License](https://img.shields.io/cocoapods/l/KeychainStore.svg)
[![codebeat badge](https://codebeat.co/badges/8f7dfcf7-6beb-49a1-95f8-02363be219ee)](https://codebeat.co/projects/github-com-juanjoarreola-keychainstore-master)

## Usage

`KeychainStore<T: Codable>` is a generic class that stores instances of classes that conform to the `Codable` protocol
```swift
let store = KeychainStore<Card>(account: "test")
let card = Card(number: "4111111111111111", name: "Me")

// save card:
try store.set(object: card, forKey: "my card")
// 	or:
try store.set(object: card, forKey: "my card", accessibility: .whenPasscodeSetThisDeviceOnly)

// get card
let card = try store.object(forKey: "my card")
```

Additionally, the class `KeychainStringStore` saves `String` instances in the Keychain.
