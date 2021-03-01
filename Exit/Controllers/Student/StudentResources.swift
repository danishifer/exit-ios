//
//  StudentResources.swift
//  MyKey
//
//  Created by Dani Shifer on 06/02/2020.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import Foundation
import PromiseKit
import MyKeyKit

extension Notification.Name {
    static let didFetchStudentExtendedData = Notification.Name("didFetchStudentExtendedData")
}

class StudentResources {
    private static func fetchUser(client: MyKeyStudentClient, device: Device) -> Promise<()> {
        return Promise { seal in
            firstly {
                DataStore.shared.getStudentUser(id: device.userId)
            }.done { user in
                // Check if user was already fetched
                guard user == nil else {
                    seal.fulfill(())
                    return
                }
                
                firstly {
                    client.getUser(GetUserRequest())
                }.map { studentUser in
                    return RealmStudentUser(studentUser)
                }.then { user in
                    DataStore.shared.addStudentUser(user)
                }.done { _ in
                    seal.fulfill(())
                }.catch { err in seal.reject(err) }
            }.catch { err in seal.reject(err) }
        }
    }
    
    private static func fetchUserDevicesMetadata(client: MyKeyStudentClient) -> Promise<()> {
        firstly {
            client.getUserDevicesMetadata(GetUserDevicesMetadataRequest())
        }.mapValues { deviceMetadata in
            RealmDeviceMetadata(deviceMetadata)
        }.done { devicesMetadata in
            DataStore.shared.replaceDevicesMetadata(with: devicesMetadata)
        }
    }
    
    private static func fetchTerminalsMetadata(client: MyKeyStudentClient) -> Promise<()> {
        firstly {
            client.getTerminalsMetadata(GetTerminalsMetadataRequest())
        }.mapValues { terminalMetadata in
            RealmTerminalMetadata(terminalMetadata)
        }.done { terminalsMetadata in
            DataStore.shared.addTerminalsMetadata(terminalsMetadata)
        }
    }
    
    private static func fetchClassesMetadata(client: MyKeyStudentClient) -> Promise<()> {
        firstly {
            client.getClassesMetadata(GetClassesMetadataRequest())
        }.mapValues { classMetadata in
            return RealmClassMetadata(classMetadata)
        }.done { classes in
             DataStore.shared.addClassesMetadata(classes)
        }
    }
    
    private static func fetchDeviceDefinitions(client: MyKeyStudentClient) -> Promise<()> {
        firstly {
            client.getDeviceDefinitions(GetDeviceDefinitionsRequest())
        }.mapValues { deviceDefinition in
            return RealmDeviceDefinition(deviceDefinition)
        }.done { deviceDefinitions in
            DataStore.shared.addDeviceDefinitions(deviceDefinitions)
        }
    }
    
    static func fetchTodayActions(client: MyKeyStudentClient) -> Promise<()> {
        firstly {
            client.getStudentActions(GetStudentActionsRequest.today())
        }.mapValues { action in
            RealmAction(action)
        }.done { actions in
            DataStore.shared.replaceTodayActions(with: actions)
        }
    }
    
    static func fetchBaseData(client: MyKeyStudentClient, device: Device) -> Promise<Void> {
        return when(fulfilled: [
            fetchUser(client: client, device: device),
            fetchUserDevicesMetadata(client: client),
        ])
    }
    
    static func fetchPermits(client: PermitsAPI) -> Promise<()> {
        firstly {
            client.getUserPermits(GetUserPermitsRequest())
        }.mapValues { permit in
            RealmPermit(permit)
        }.done { permits in
            DispatchQueue.main.async {
                DataStore.shared.replacePermits(with: permits)
            }
        }
    }
    
    static func fetchExtendedData(client: MyKeyStudentClient) -> Promise<Void> {
        return when(fulfilled: [
            fetchPermits(client: client),
            fetchTerminalsMetadata(client: client),
            fetchClassesMetadata(client: client),
            fetchDeviceDefinitions(client: client)
        ]).done {
            NotificationCenter.default.post(name: .didFetchStudentExtendedData, object: self)
        }
    }
}
