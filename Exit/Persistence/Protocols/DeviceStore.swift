//
//  DeviceStore.swift
//  MyKey
//
//  Created by Dani Shifer on 2/6/20.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import MyKeyKit

protocol DeviceStore {
    func saveDevice(_ device: Device)
    func loadDevice() -> Device?
    func removeDevice()
}
