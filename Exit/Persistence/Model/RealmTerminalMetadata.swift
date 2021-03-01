//
//  RTerminalMetadata.swift
//  MyKey
//
//  Created by Dani Shifer on 19/12/2019.
//  Copyright © 2019 Dani Shifer. All rights reserved.
//

import RealmSwift
import MyKeyKit

class RealmTerminalMetadata: Object {
    @objc dynamic var id: String = ""
    
    @objc private dynamic var friendlyNameData: Data?
    @objc dynamic var friendlyName: [String: String] {
        get {
            guard let data = friendlyNameData else {
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
                friendlyNameData = data
            } catch {
                friendlyNameData = nil
            }
        }
    }
    
    override class func ignoredProperties() -> [String] {
        return ["friendlyName"]
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    init(_ terminalMetadata: TerminalMetadata) {
        super.init()
        self.id = terminalMetadata.id
        self.friendlyName = terminalMetadata.friendlyName
    }
    
    required init() {}
    
    func localizedName() -> String? {
        let name = self.friendlyName
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
