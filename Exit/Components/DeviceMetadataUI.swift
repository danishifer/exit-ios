//
//  DeviceUI.swift
//  MyKey
//
//  Created by Dani Shifer on 2/6/20.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import UIKit
import MyKeyKit

class DeviceMetadataUI {
    static func icon(for device: RealmDeviceMetadata) -> UIImage? {
        let deviceId = device.id
        switch deviceId.prefix(1) {
        case "c":
            return UIImage(named: "card_template")
        case "d":
            return UIImage(named: "phone_template")
        default:
            return nil
        }
    }
    
//    static func type(for action: RealmStudentAction) -> String {
//        return NSLocalizedString(
//            action.type,
//            tableName: "Actions",
//            bundle: .main,
//            value: action.type,
//            comment: "action type"
//        )
//    }
    
    

}
