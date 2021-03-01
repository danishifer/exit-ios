//
//  SecureDeviceStore.swift
//  MyKey
//
//  Created by Dani Shifer on 2/6/20.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import Foundation
import MyKeyKit

extension SecureStore: DeviceStore {
    static let kKeychainDeviceKey = "mykey-device"
    
    func saveDevice(_ device: Device) {
        let data = DevicePropertyListCoder.shared.encode(device: device)
        
        keychain.set(data, forKey: SecureStore.kKeychainDeviceKey)
    }
    
    public func loadDevice() -> Device? {
        guard let data = keychain.getData(SecureStore.kKeychainDeviceKey) else {
            return nil
        }
        
        return DevicePropertyListCoder.shared.decode(data: data)
    }
    
    public func removeDevice() {
        keychain.delete(SecureStore.kKeychainDeviceKey)
    }
}

fileprivate class DevicePropertyListCoder {
    
    static let shared = DevicePropertyListCoder()
    
    // MARK: - Methods
    init() {}
    
    func encode(device: Device) -> Data {
        return try! PropertyListEncoder().encode(device)
    }
    
    func decode(data: Data) -> Device {
        return try! PropertyListDecoder().decode(Device.self, from: data)
    }
    
}
