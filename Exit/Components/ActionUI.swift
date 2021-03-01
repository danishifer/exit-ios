//
//  ActionUI.swift
//  MyKey
//
//  Created by Dani Shifer on 12/18/19.
//  Copyright © 2019 Dani Shifer. All rights reserved.
//

import UIKit
import MyKeyKit

class ActionUI {
    static func icon(for action: RealmAction) -> UIImage? {
        let deviceId = action.deviceId
        switch deviceId.prefix(1) {
        case "c":
            return UIImage(named: "action.\(action.type).card")
        case "d":
            return UIImage(named: "action.\(action.type).phone")
        default:
            return nil
        }
    }
    
    static func type(for action: RealmAction) -> String {
        return NSLocalizedString(
            action.type,
            tableName: "Actions",
            bundle: .main,
            value: action.type,
            comment: "action type"
        )
    }
    
    static func time(format: String, for action: RealmAction) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: action.date)
    }
    
    static func status(for action: RealmAction) -> String {
        return NSLocalizedString(
            "_status-\(action.status)",
            tableName: "Actions",
            bundle: .main,
            value: "",
            comment: "action status"
        )
    }
}
