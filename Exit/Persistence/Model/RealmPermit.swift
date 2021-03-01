//
//  RealmPermit.swift
//  MyKey
//
//  Created by Dani Shifer on 2/8/20.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import RealmSwift
import MyKeyKit

class RealmPermit: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var status: Int32 = 0

    @objc dynamic var type: String = ""

    let assignedTo = List<String>()
    @objc dynamic var requestedOn: Date = Date()
    @objc dynamic var requestedBy: String = ""

    let users = List<String>()

    @objc dynamic var schedule: RealmPermitSchedule? = nil

    @objc dynamic var title: String? = nil
    @objc dynamic var note: String? = nil

    @objc dynamic var approvedOn: Date? = nil
    @objc dynamic var approvedBy: String? = nil
    @objc dynamic var approvedNote: String? = nil

    @objc dynamic var rejectedOn: Date? = nil
    @objc dynamic var rejectedBy: String? = nil
    @objc dynamic var rejectedNote: String? = nil
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    init(_ permit: Permit) {
        self.id = permit.id
        self.status = permit.status
        self.type = permit.type
        self.assignedTo.append(objectsIn: permit.assignedTo)
        self.requestedOn = permit.requestedOn
        self.requestedBy = permit.requestedBy
        self.users.append(objectsIn: permit.users)
        self.schedule = RealmPermitSchedule(permit.schedule)
        self.title = permit.title
        self.note = permit.note
        self.approvedOn = permit.approvedOn
        self.approvedBy = permit.approvedBy
        self.approvedNote = permit.approvedNote
        self.rejectedOn = permit.rejectedOn
        self.rejectedBy = permit.rejectedBy
        self.rejectedNote = permit.rejectedNote
    }
    
    required init() {}
    
    func isValidForToday() -> Bool {
        guard let schedule = self.schedule else { return false }
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = 23
        dateComponents.minute = 59
        dateComponents.second = 59
        
        guard let dayEnd = Calendar.current.date(from: dateComponents) else {
            print("cannot construct dayEnd date")
            return false
        }
        
        if schedule.startDate > dayEnd { return false }
        
        switch schedule.repeat {
        case "none":
            if schedule.endDate < dayEnd { return false }
        default:
            guard let repeatEndDate = schedule.repeatEndDate else { return false }
            if repeatEndDate < dayEnd { return false }
            
            let hour = Calendar.current.component(.hour, from: dayEnd)
            let minute = Calendar.current.component(.minute, from: dayEnd)
            
            let startHour = Calendar.current.component(.hour, from: schedule.startDate)
            let startMinute = Calendar.current.component(.minute, from: schedule.startDate)
            
            if startHour > hour { return false }
            if startHour == hour && startMinute > minute { return false }
            
            switch schedule.repeat {
            case "weekly":
                let startWeekday = Calendar.current.component(.weekday, from: schedule.startDate)
                let currWeekday = Calendar.current.component(.weekday, from: dayEnd)
                if startWeekday != currWeekday { return false }
                break
            case "daily":
                break
            default:
                return false
            }
        }
        
        return true
    }
    
    enum Status: Int32 {
        case pending = 0
        case approved = 1
        case rejected = 2
    }
}

class RealmPermitSchedule: Object {
    @objc dynamic var `repeat`: String = ""
    @objc dynamic var repeatEndDate: Date? = nil
    
    @objc dynamic var startDate: Date = Date()
    @objc dynamic var endDate: Date = Date()
    
    init(_ permitSchedule: PermitSchedule) {
        self.repeat = permitSchedule.repeat
        self.repeatEndDate = permitSchedule.repeatEndDate
        
        self.startDate = permitSchedule.startDate
        self.endDate = permitSchedule.endDate
    }
    
    required init() {}
}
