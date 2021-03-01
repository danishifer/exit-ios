//
//  RealmDeviceDefinition.swift
//  MyKey
//
//  Created by Dani Shifer on 2/7/20.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import RealmSwift
import MyKeyKit

class RealmDeviceDefinition: Object {
    @objc dynamic var type: String = ""
    
    @objc private dynamic var nameData: Data?
    @objc dynamic var name: [String: String] {
        get {
            guard let data = nameData else {
                return [String: String]()
            }
            
            do {
                let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
                return dict!
            } catch {
                return [String: String]()
            }
        }
        
        set {
            do {
                let data = try JSONSerialization.data(withJSONObject: newValue, options: [])
                nameData = data
            } catch {
                nameData = nil
            }
        }
    }
    
    override class func ignoredProperties() -> [String] {
        return ["name"]
    }
    
    override class func primaryKey() -> String? {
        return "type"
    }
    
    init(_ deviceDefinition: DeviceDefinition) {
        super.init()
        self.type = deviceDefinition.type
        self.name = deviceDefinition.name
    }
    
    required init() {}
    
    
    func localizedName() -> String? {
        let name = self.name
        let fallback = name.first?.value
        
        guard let languageCode = Locale.preferredLanguages.first?.prefix(2) else {
            guard let deviceLanguageCode = Locale.current.languageCode else {
                return fallback
            }
            
            return name[deviceLanguageCode] ?? fallback
        }
        
        return name[String(languageCode)] ?? fallback
    }
}

