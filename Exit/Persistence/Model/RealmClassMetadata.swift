//
//  RealmClassMetadata.swift
//  MyKey
//
//  Created by Dani Shifer on 06/02/2020.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import RealmSwift
import MyKeyKit

class RealmClassMetadata: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    init(_ classMetadata: ClassMetadata) {
        super.init()
        self.id = classMetadata.id
        self.name = classMetadata.name
    }
    
    required init() {}
}
