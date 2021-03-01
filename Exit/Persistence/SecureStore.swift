//
//  SecureStore.swift
//  MyKey
//
//  Created by Dani Shifer on 2/6/20.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import Foundation
import KeychainSwift

public class SecureStore {
    
    // MARK: - Shared Instances
    static let shared = SecureStore()
    
    // MARK: - Properties
    let keychain: KeychainSwift
    
    // MARK: - Methods
    init() {
        self.keychain = KeychainSwift()
    }
    
}

extension SecureStore {
    static let kKeychainRoleKey = "mykey-role"
    
    func setRole(_ role: String) {
        self.keychain.set(role, forKey: SecureStore.kKeychainRoleKey)
    }
    
    func getRole() -> String? {
        return self.keychain.get(SecureStore.kKeychainRoleKey)
    }
}

extension SecureStore {
    static let kKeychainInstituteIdKey = "mykey-institute-id"
    
    func setInstituteId(_ id: String) {
        self.keychain.set(id, forKey: SecureStore.kKeychainInstituteIdKey)
    }
    
    func getInstituteId() -> String? {
        return self.keychain.get(SecureStore.kKeychainInstituteIdKey)
    }
}

extension SecureStore {
    static let kKeychainInstituteURLKey = "mykey-institute-url"
    
    func setInstituteURL(_ url: String) {
        self.keychain.set(url, forKey: SecureStore.kKeychainInstituteURLKey)
    }
    
    func getInstituteURL() -> String? {
        self.keychain.get(SecureStore.kKeychainInstituteURLKey)
    }
}

