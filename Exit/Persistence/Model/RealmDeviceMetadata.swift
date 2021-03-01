//
//  RealmDeviceMetadata.swift
//  MyKey
//
//  Created by Dani Shifer on 2/6/20.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import RealmSwift
import MyKeyKit

class RealmDeviceMetadata: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var status: Int32 = 0
    @objc dynamic var userId: String = ""
    
    @objc dynamic var deviceName: String? = nil
    @objc dynamic var deviceInfo: String? = nil
    
    @objc dynamic var cardNumber: String? = nil
    @objc dynamic var cardSerial: String? = nil
    
    @objc dynamic var activatedOn: Date? = nil
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    init(_ deviceMetadata: DeviceMetadata) {
        self.id = deviceMetadata.id
        self.type = deviceMetadata.type
        self.status = deviceMetadata.status
        self.userId = deviceMetadata.userId
        
        self.deviceName = deviceMetadata.deviceName
        self.deviceInfo = deviceMetadata.deviceInfo
        
        self.cardNumber = deviceMetadata.cardNumber
        self.cardSerial = deviceMetadata.cardSerial
        
        self.activatedOn = deviceMetadata.activatedOn
    }
    
    required init() {}
    
}
