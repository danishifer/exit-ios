//
//  RealmStudentAction.swift
//  MyKey
//
//  Created by Dani Shifer on 12/20/19.
//  Copyright © 2019 Dani Shifer. All rights reserved.
//

import RealmSwift
import MyKeyKit

class RealmAction: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var userId: String = ""
    @objc dynamic var status: Int32 = 0
    @objc dynamic var type: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var deviceId: String = ""
    @objc dynamic var terminalId: String = ""
    @objc dynamic var permitId: String?
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    init(_ action: StudentAction) {
        self.id = action.id
        self.userId = action.userId
        self.status = action.status
        self.type = action.type
        self.date = action.date
        self.deviceId = action.deviceId
        self.terminalId = action.terminalId
        self.permitId = action.permitId
    }
    
    required init() {}
    
    enum Status: Int32 {
        case pending = 0
        case approved = 1
        case rejected = 2
    }
}
