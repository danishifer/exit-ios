//
//  RealmStudentUser.swift
//  MyKey
//
//  Created by Dani Shifer on 21/01/2020.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import RealmSwift
import MyKeyKit

class RealmStudentUser: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: RealmStudentName? = nil
    @objc dynamic var homeroom: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    init(_ studentUser: StudentUser) {
        self.id = studentUser.id
        self.name = RealmStudentName(studentUser.name)
        self.homeroom = studentUser.homeroom
    }
    
    required init() {}
    
}


class RealmStudentName: Object {
    @objc dynamic var given: String = ""
    @objc dynamic var middle: String = ""
    @objc dynamic var family: String = ""
    
    init(_ studentName: StudentName) {
        self.given = studentName.given
        self.middle = studentName.middle
        self.family = studentName.family
    }
    
    required init() {}
    
    func string() -> String {
        return "\(self.given) \(self.family)"
    }
}
