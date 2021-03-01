//
//  FirstViewController.swift
//  MyKey
//
//  Created by Dani Shifer on 12/6/19.
//  Copyright © 2019 Dani Shifer. All rights reserved.
//

import UIKit
import CoreNFC

import PromiseKit
import RealmSwift
import MyKeyKit

class TodayViewController: UIViewController, StudentClientConsumer {
    
    var client: MyKeyStudentClient!
    
    var todayActions: [RealmAction] = []
    var todayActionsCellData: [ActionCellData] = []
    
    private var actionLoadingDelegate: ActionLoadingDelegate?
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet var currentStatusTime: UILabel!
    @IBOutlet var currentStatusName: UILabel!
    @IBOutlet var currentStatusNameTopConstraint: NSLayoutConstraint!
    @IBOutlet var currentStatusIcon: UIImageView!
    
    @IBOutlet var earliestExitTime: UILabel!
    
    
    var permitsNotificationToken: NotificationToken? = nil
    
    @IBOutlet weak var useAsCardButton: UIButton!
    @IBAction func useAsCardPressed(_ sender: UIButton) {
        guard NFCNDEFReaderSession.readingAvailable else {
            #if targetEnvironment(simulator)
                // Simulate Card Read
                let uid = "043D8DC2C44880"
                self.performAction(of: "exit", cardSerial: uid)
            #else
                print("reading not available")
            #endif
            return
        }
        
        let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session.alertMessage = NSLocalizedString("nfc-prompt", comment: "NFC Prompt Instruction")
        session.begin()
    }
    
    func performAction(of type: String, cardSerial: String) {
        self.performSegue(withIdentifier: "ShowActionLoading", sender: self)
        
        firstly {
            self.requestAction(of: type, cardSerial: cardSerial)
        }.get { action in
            DataStore.shared.addAction(action)
        }.done { action in
            switch action.status {
            case RealmAction.Status.approved.rawValue:
                // Action is approved, reload actions and update table
                self.actionLoadingDelegate?.didApproveAction(action)
                self.reloadActionsUI()
                
            case RealmAction.Status.rejected.rawValue:
                // Action is rejected, no need to update actions table
                self.actionLoadingDelegate?.didRejectAction()
                
            default:
                print("invalid status")
            }
        }.cauterize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowActionLoading" {
            if let actionNavController = segue.destination as? UINavigationController {
                if let actionLoadingVC = actionNavController.topViewController as? ActionLoadingViewController {
                    self.actionLoadingDelegate = actionLoadingVC
                }
            }
        }
    }
    
    @IBOutlet var actionsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIView.userInterfaceLayoutDirection(for: useAsCardButton.semanticContentAttribute) == .rightToLeft {
            useAsCardButton.imageEdgeInsets.left = 0
            useAsCardButton.imageEdgeInsets.right = -20
        }
        
        
        // Load actions table and status block from cache
        reloadActionsUI()
        
        // Load earliest exit time from cache
        reloadEarliestExitTime()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishFetchingExtendedData), name: .didFetchStudentExtendedData, object: nil)
        
        permitsNotificationToken = DataStore.shared.getPermits().observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .update(_, deletions: _, insertions: let insertions, modifications: let modifications):
                if insertions.count > 0 || modifications.count > 0 {
                    self?.reloadEarliestExitTime()
                }
            default:
                break
            }
        }
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        actionsTableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh actions table from remote
        DispatchQueue.global(qos: .background).async {
            self.refreshTodayActions()
                .catch { err in
                    print("Failed to refresh today actions: \(err)")
                }
        }
    }
    
    @objc private func didFinishFetchingExtendedData() {
        self.reloadTodayActionsTable()
    }
    
    @objc private func refresh() {
        when(fulfilled: [
            refreshPermits(),
            refreshTodayActions()
        ]).ensure {
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }.catch { err in
            print("Refresh failed: \(err)")
        }
    }
    
    private func refreshPermits() -> Promise<()> {
        StudentResources.fetchPermits(client: client)
    }
    
    private func refreshTodayActions() -> Promise<()> {
        firstly {
            StudentResources.fetchTodayActions(client: client)
        }.done {
            self.reloadActionsUI()
        }
    }
    
    private func reloadActionsUI() {
        self.reloadTodayActions()
        self.reloadTodayActionsTable()
        self.reloadCurrentStatus()
    }
    
    func reloadTodayActions() {
        let actions = DataStore.shared.getTodayActions()
        
        self.todayActions = Array(actions)
    }
    
    func reloadTodayActionsTable() {
        self.todayActionsCellData = todayActions.map { action in
            ActionCellData.from(action: action)
        }
        
        let actionsSections = IndexSet(integer: 0)
        self.actionsTableView.reloadSections(actionsSections, with: .automatic)
    }
    
    func isValid(permit: RealmPermit, for date: Date) -> Bool {
        guard let schedule = permit.schedule else { return false }
        switch schedule.repeat {
        case "none":
            if schedule.endDate < date { return false }
        default:
            guard let repeatEndDate = schedule.repeatEndDate else { return false }
            if repeatEndDate < date { return false }
            
            let hour = Calendar.current.component(.hour, from: date)
            let minute = Calendar.current.component(.minute, from: date)
            
            let startHour = Calendar.current.component(.hour, from: schedule.startDate)
            let startMinute = Calendar.current.component(.minute, from: schedule.startDate)
            let endHour = Calendar.current.component(.hour, from: schedule.endDate)
            let endMinute = Calendar.current.component(.minute, from: schedule.endDate)
            
            if startHour > hour { return false }
            if startHour == hour && startMinute > minute { return false }
            
            if endHour < hour { return false }
            if endHour == hour && endMinute < minute { return false }
            
            switch schedule.repeat {
            case "weekly":
                let weekday = Calendar.current.component(.weekday, from: date)
                let startWeekday = Calendar.current.component(.weekday, from: schedule.startDate)
                
                if startWeekday != weekday { return false }
                break
            case "daily":
                break
            default:
                return false
            }
        }
        
        return true
    }
    
    func reloadEarliestExitTime() {
        DispatchQueue.global(qos: .background).async {
            
            // Accessing realm from background thread requires
            // creating a new realm on target thread
            let permit = DataStore().getPermits()
                .filter("status == %@ && type == %@", RealmPermit.Status.approved.rawValue, "exit")
                .filter { $0.isValidForToday() }
                .sorted { (permitA, permitB) -> Bool in
                    let aHour = Calendar.current.component(.hour, from: permitA.schedule!.startDate)
                    let aMinute = Calendar.current.component(.minute, from: permitA.schedule!.startDate)
                    let bHour = Calendar.current.component(.hour, from: permitB.schedule!.startDate)
                    let bMinute = Calendar.current.component(.minute, from: permitB.schedule!.startDate)
                    
                    return aHour < bHour || (aHour == bHour && aMinute < bMinute)
                }.first
            
            guard permit != nil else {
                return DispatchQueue.main.async {
                    self.earliestExitTime.text = "--"
                }
            }
            
            let time = PermitUI.startTime(format: "HH:mm", for: permit!)
            
            DispatchQueue.main.async {
                self.earliestExitTime.text = "\(time)"
            }
        }
    }
    
    func reloadCurrentStatus() {
        guard let action = todayActions.first else {
            // No actions today, status is undefined
            currentStatusName.text = NSLocalizedString(
                "_unregistered",
                tableName: "Actions",
                bundle: .main,
                value: "Unregistered",
                comment: "unregistered"
            )
            currentStatusTime.text = ""
            currentStatusIcon.image = UIImage(named: "warning_template")
            currentStatusIcon.tintColor = UIColor.systemOrange
            return
        }
        
        currentStatusTime.text = ActionUI.time(format: "HH:mm", for: action)
        currentStatusIcon.image = ActionUI.icon(for: action)
        
        switch action.type {
        case "enter":
            currentStatusName.text = NSLocalizedString(
                "_checked-in",
                tableName: "Actions",
                bundle: .main,
                value: "Checked In",
                comment: "checked in"
            )
        case "exit":
            currentStatusName.text = NSLocalizedString(
                "_checked-out",
                tableName: "Actions",
                bundle: .main,
                value: "Checked Out",
                comment: "checked out"
            )
        default:
            print("Unsupported action type")
        }
    }
    
    func requestAction(of type: String, cardSerial: String) -> Promise<RealmAction> {
        return firstly {
            client.createStudentAction(CreateStudentActionRequest(type: type, cardSerial: cardSerial))
        }.map { action in
            return RealmAction(action)
        }
    }
}


extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("today-actions-header", comment: "actions")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard todayActionsCellData.count > indexPath.row else {
            return 44
        }
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if todayActionsCellData.count == 0 {
            switch indexPath.row {
            case 0:
                return tableView.dequeueReusableCell(withIdentifier: "NoActionsToday")!
//            case 1:
//                return tableView.dequeueReusableCell(withIdentifier: "ViewActionsHistory")!
            default:
                return UITableViewCell()
            }
        }
        
        switch indexPath.row {
        case 0..<todayActionsCellData.count:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Action") as! ActionCell
            let actionData = todayActionsCellData[indexPath.row]
            
            cell.icon.image = actionData.icon
            cell.typeLabel.text = actionData.type
            cell.timeLabel.text = actionData.time
            cell.locationLabel.text = actionData.location
            
            return cell
//        case todayActionsCellData.count:
//            return tableView.dequeueReusableCell(withIdentifier: "ViewActionsHistory")!
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard todayActionsCellData.count > 0 else { return 1 }
        return todayActionsCellData.count
    }
}
