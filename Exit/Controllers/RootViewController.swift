//
//  RootViewController.swift
//  MyKey
//
//  Created by Dani Shifer on 1/18/20.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import UIKit
import PromiseKit
import MyKeyKit

extension Notification.Name {
    static let didCompleteActivation = Notification.Name("didCompleteActivation")
}

class RootViewController: UIViewController {
    
    static let kInitialAppLaunchStudent = "_initial-launch-student"
    
    
    // MARK: - Outlets
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Listen for activation completion
        NotificationCenter.default.addObserver(self, selector: #selector(didCompleteActivation), name: .didCompleteActivation, object: nil)
        
        if #available(iOS 13.0, *) {
            activityIndicator.style = .medium
        }
        
        setActivityIndicatorVisible(false)
    }
    
    func setActivityIndicatorVisible(_ visible: Bool) {
        activityIndicator.color = visible ? .none : .clear
    }
    
    @objc func didCompleteActivation() {
        redirect()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        redirect()
    }
    
    
//    /**
//     Loads the device from the SecureStore.
//
//     - Returns: A boolean indicating whether the device was loaded properly.
//     */
//    func loadDevice() -> Device? {
//        return SecureStore.shared.loadDevice() else {
//            return false
//        }
//
//        self.device = device
//        return true
//    }
    
    func redirect() {
        guard let device = SecureStore.shared.loadDevice() else {
            print("[RootViewController] no device found")
            showWelcome()
            return
        }
        
        guard let instituteId = SecureStore.shared.getInstituteId() else {
            print("[RootViewController] institute id is missing")
            showWelcome()
            return
        }
        
        guard let instituteURL = SecureStore.shared.getInstituteURL() else {
            print("[RootViewController] institute url is missing")
            showWelcome()
            return
        }
        
        guard let role = SecureStore.shared.getRole() else {
            print("[RootViewController] user role is undefined")
            showWelcome()
            return
        }
        
        switch role {
        case "student":
            
                self.showStudent(device: device, instituteId: instituteId, instituteURL: instituteURL)
            
        default:
            print("[RootViewController] role '\(role)' is not supported")
            showWelcome()
            return
        }
    }
    
    func fetchStudentExtendedData(client: MyKeyStudentClient) -> Promise<()> {
        Promise { seal in
            if !UserDefaults.standard.bool(forKey: RootViewController.kInitialAppLaunchStudent) {
                // Initial app launch, wait for the extended data
                setActivityIndicatorVisible(true)
                firstly {
                    StudentResources.fetchExtendedData(client: client)
                }.ensure {
                    self.setActivityIndicatorVisible(false)
                }.done {
                    UserDefaults.standard.set(true, forKey: RootViewController.kInitialAppLaunchStudent)
                    
                    seal.fulfill(())
                }.catch { err in
                    seal.reject(err)
                }
            } else {
                // App has already been run before, refresh the
                // data on a background task
                DispatchQueue.global(qos: .background).async {
                    StudentResources.fetchExtendedData(client: client)
                        .catch { err in
                            print("[RootViewController] error fetching extended data: \(err)")
                        }
                }
                seal.fulfill(())
            }
        }
    }
    
    func showStudent(device: Device, instituteId: String, instituteURL: String) {
        // Use data from device to build the client
        let studentClient = MyKeyStudentClient(host: instituteURL, device: device)
        
        firstly {
            StudentResources.fetchBaseData(client: studentClient, device: device)
        }.then {
            self.fetchStudentExtendedData(client: studentClient)
        }.done {
            self.performSegue(withIdentifier: "ShowStudent", sender: studentClient)
        }.catch { err in
            print("[RootViewController]: error fetching student data: \(err)")
            self.handleNetworkError(err)
        }
    }
    
    func handleNetworkError(_ err: Error) {
        switch err {
        case let MyKeyClientError.statusWithPayload(code, payload):
            print("[RootViewController]: handleNetworkError [\(code)]: \(payload)")
            switch code {
            case 401:
                self.showWelcome()
            default:
                self.statusLabel.text = NSLocalizedString("service-unavailable", comment: "")
            }
            
        default:
            print(err)
            self.statusLabel.text = "Unknown error occured"
        }
    }
    
    func showWelcome() {
        self.performSegue(withIdentifier: "ShowWelcome", sender: self)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var vc = segue.destination as? StudentClientConsumer {
            let client = sender as! MyKeyStudentClient
            vc.client = client
        }
    }
}
