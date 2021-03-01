//
//  PermitUI.swift
//  MyKey
//
//  Created by Haim Marcovici on 08/02/2020.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import Foundation

class PermitUI {
    private static func time(format: String, for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    static func startTime(format: String, for permit: RealmPermit) -> String {
        return self.time(format: format, for: permit.schedule!.startDate)
    }
    
    static func endTime(format: String, for permit: RealmPermit) -> String {
        return self.time(format: format, for: permit.schedule!.endDate)
    }
}
