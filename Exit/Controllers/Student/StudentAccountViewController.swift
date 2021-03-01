//
//  StudentAccountViewController.swift
//  MyKey
//
//  Created by Dani Shifer on 1/20/20.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import UIKit
import PromiseKit
import MyKeyKit

class StudentAccountViewController: UITableViewController, StudentClientConsumer {

    var client: MyKeyStudentClient!
    
    var user: RealmStudentUser?
    var institute: RealmInstituteMetadata?
    
    var deviceDefinitions: [RealmDeviceDefinition] = []
    
    var homeroomClassMetadata: RealmClassMetadata?
    var userDevicesMetadata: [RealmDeviceMetadata] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Observe when extended data fetch is complete (classes metadata, device definitions)
        NotificationCenter.default.addObserver(self, selector: #selector(loadData),name: .didFetchStudentExtendedData, object: nil)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("account-deactivate", comment: "deactivate"), style: .plain, target: self, action: #selector(confirmDeactivation))
        
        guard let device = SecureStore.shared.loadDevice() else {
            print("no device")
            return
        }
        
        firstly {
            DataStore.shared.getStudentUser(id: device.userId)
        }.done { user in
            guard let user = user else {
                print("no user")
                return
            }
            
            self.user = user
            
            // Load table view data
            self.loadData()
        }.cauterize()
    }
    
    @objc func loadData() {
        if let instituteId = SecureStore.shared.getInstituteId() {
            self.institute = DataStore.shared.getInstituteMetadata(id: instituteId)
        }
        
        if let user = self.user {
            self.homeroomClassMetadata = DataStore.shared.getClass(by: user.homeroom)
        }
        
        self.userDevicesMetadata = Array(DataStore.shared.getDevicesMetadata().sorted(byKeyPath: "type"))
        self.deviceDefinitions = Array(DataStore.shared.getDeviceDefinitions())
        
        self.tableView.reloadData()
    }
    
    
    @objc func confirmDeactivation() {
        let alert = UIAlertController(title: NSLocalizedString("account-deactivate-title", comment: "confirm deactivation"), message: NSLocalizedString("account-deactivate-message", comment: ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("account-deactivate-confirm", comment: "deactivate"), style: .destructive, handler: deactivate))
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("account-deactivate-cancel", comment: "cancel"), style: .default, handler: nil)
        alert.addAction(cancelAction)
        alert.preferredAction = cancelAction
        
        self.present(alert, animated: true)
    }
    
    func deactivate(_ action: UIAlertAction) {
        print("deactivate")
        
        firstly {
            self.client.deactivateDevice(.init())
        }.get { status in
            print("status: \(status)")
        }.done { _ in
            SecureStore.shared.removeDevice()
            self.navigationController?.navigationController?.popToRootViewController(animated: true)
        }.cauterize()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return self.userDevicesMetadata.count
        default:
            return 1
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("account-profile-header", comment: "profile")
        case 1:
            return NSLocalizedString("account-devices-header", comment: "devices")
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 60
            }
            
            return tableView.rowHeight
        }
        
        return 60
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Profile") as! ProfileCell
                cell.nameLabel.text = user?.name?.string()
                cell.instituteLabel.text = self.institute?.localizedName()
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileClassCell")!
            
            if let className = self.homeroomClassMetadata?.name {
                cell.detailTextLabel?.text = NSLocalizedString(className, tableName: "Classes", bundle: .main, value: className, comment: "")
            } else {
                cell.detailTextLabel?.text = user?.homeroom
            }
            
            
            return cell
        }
        
        guard self.userDevicesMetadata.indices.contains(indexPath.row) else {
            return UITableViewCell()
        }
        
        let device = self.userDevicesMetadata[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceMetadataCell") as! DeviceMetadataCell
        cell.icon.image = DeviceMetadataUI.icon(for: device)
        
        let deviceDefintion = deviceDefinitions.first { defenition -> Bool in
            return defenition.type == device.type
        }
        
        switch device.type {
        case let str where str.starts(with: "card"):
            cell.nameLabel.text = deviceDefintion?.localizedName() ?? device.type
            cell.infoLabel.text = device.cardNumber
        case let str where str.starts(with: "phone"):
            cell.nameLabel.text = device.deviceName
            cell.infoLabel.text = device.deviceInfo
        default:
            break
        }
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
