//
//  DataStore.swift
//  MyKey
//
//  Created by Dani Shifer on 19/12/2019.
//  Copyright © 2019 Dani Shifer. All rights reserved.
//

import Foundation
import RealmSwift
import PromiseKit

class DataStore {
    
    // MARK: - Properties
    static let shared = DataStore()
    
    private let realm: Realm
    
    
    // MARK: - Methods
    init() {
        do {
            self.realm = try Realm()
        } catch {
            fatalError("cannot open realm: \(error)")
        }
    }
    
    enum StoreError: Error {
        case notFound
    }
}

extension DataStore {
    func addAction(_ action: RealmAction) -> ()? {
        return try? self.realm.write {
            self.realm.add(action, update: .modified)
        }
    }
    
    func addActions(_ actions: [RealmAction]) -> ()? {
        return try? self.realm.write {
            self.realm.add(actions, update: .modified)
        }
    }
    
    func getActions() -> Promise<Results<RealmAction>> {
        return Promise { seal in
            seal.fulfill(self.realm.objects(RealmAction.self))
        }
    }
    
    func replaceTodayActions(with actions: [RealmAction]) -> ()? {
        let toDelete = self.getTodayActions().filter{ action in
            return actions.first{ $0.id == action.id } == nil
        }
        try? self.realm.write {
            self.realm.delete(toDelete)
        }
        
        return addActions(actions)
    }
    
    func getTodayActions() -> Results<RealmAction> {
        let currDate = Date()
        
        let fromDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: currDate)!
        let toDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: currDate)!
        
        return self.realm.objects(RealmAction.self)
            .filter("status != %@", RealmAction.Status.rejected.rawValue)
            .filter("date >= %@ AND date <= %@", fromDate, toDate)
            .sorted(byKeyPath: "date", ascending: false)
    }
}

extension DataStore {
    func getPermits() -> Results<RealmPermit> {
        return self.realm.objects(RealmPermit.self)
    }
    
    func addPermits(_ permits: [RealmPermit]) -> ()? {
        return try? self.realm.write {
            self.realm.add(permits, update: .modified)
        }
    }
    
    func replacePermits(with permits: [RealmPermit]) -> ()? {
        let toDelete = self.realm.objects(RealmPermit.self).filter{ permit in
            return permits.first{ $0.id == permit.id } == nil
        }
        try? self.realm.write {
            self.realm.delete(toDelete)
        }
        
        return addPermits(permits)
    }
}

extension DataStore {
    func addTerminalsMetadata(_ terminals: [RealmTerminalMetadata]) -> ()? {
        return try? self.realm.write {
            self.realm.add(terminals, update: .modified)
        }
    }
    
    func getTerminalMetadata(by id: String) -> RealmTerminalMetadata? {
        return self.realm.object(ofType: RealmTerminalMetadata.self, forPrimaryKey: id)
    }
}

extension DataStore {
    func addStudentUser(_ user: RealmStudentUser) -> Promise<RealmStudentUser> {
        return Promise { seal in
            try self.realm.write {
                self.realm.add(user, update: .modified)
            }
            seal.fulfill(user)
        }
    }
    
    func getStudentUser(id userId: String) -> Promise<RealmStudentUser?> {
        return Promise { seal in
            let user = self.realm.object(ofType: RealmStudentUser.self, forPrimaryKey: userId)
            seal.fulfill(user)
        }
    }
}

extension DataStore {
    func addDevicesMetadata(_ devicesMetadata: [RealmDeviceMetadata]) -> ()? {
        return try? self.realm.write {
            self.realm.add(devicesMetadata, update: .modified)
        }
    }
    
    func replaceDevicesMetadata(with devicesMetadata: [RealmDeviceMetadata]) -> ()? {
        let toDelete = realm.objects(RealmDeviceMetadata.self).filter{ device in
            return devicesMetadata.first{ $0.id == device.id } == nil
        }
        try? self.realm.write {
            self.realm.delete(toDelete)
        }
        
        return addDevicesMetadata(devicesMetadata)
    }
    
    func getDevicesMetadata() -> Results<RealmDeviceMetadata> {
        return self.realm.objects(RealmDeviceMetadata.self)
    }
}

extension DataStore {
    func addDeviceDefinitions(_ deviceDefinitions: [RealmDeviceDefinition]) -> ()? {
        return try? self.realm.write {
            self.realm.add(deviceDefinitions, update: .modified)
        }
    }
    
    func getDeviceDefinition(by type: String) -> RealmDeviceDefinition? {
        return self.realm.object(ofType: RealmDeviceDefinition.self, forPrimaryKey: type)
    }
    
    func getDeviceDefinitions() -> Results<RealmDeviceDefinition> {
        return self.realm.objects(RealmDeviceDefinition.self)
    }
}

extension DataStore {
    func addClassesMetadata(_ classes: [RealmClassMetadata]) -> ()? {
        return try? self.realm.write {
            self.realm.add(classes, update: .modified)
        }
    }
    
    func getClass(by id: String) -> RealmClassMetadata? {
        return self.realm.object(ofType: RealmClassMetadata.self, forPrimaryKey: id)
    }
}

extension DataStore {
    func addInstituteMetadata(_ instituteMetadata: RealmInstituteMetadata) -> ()? {
        return try? self.realm.write {
            self.realm.add(instituteMetadata, update: .modified)
        }
    }
    
    func getInstituteMetadata(id: String) -> RealmInstituteMetadata? {
        return self.realm.object(ofType: RealmInstituteMetadata.self, forPrimaryKey: id)
    }
}
