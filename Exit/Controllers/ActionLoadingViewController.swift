//
//  ActionLoadingViewController.swift
//  MyKey
//
//  Created by Dani Shifer on 20/01/2020.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import UIKit

protocol ActionLoadingDelegate {
    func didApproveAction(_ action: RealmAction)
    func didRejectAction()
}

class ActionLoadingViewController: UIViewController, ActionLoadingDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        
        if #available(iOS 13.0, *) {
            activityIndicator.style = .medium
        }
        
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func didApproveAction(_ action: RealmAction) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "ShowActionApproved", sender: action)
        }
    }
    
    func didRejectAction() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "ShowActionRejected", sender: nil)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        self.activityIndicator.stopAnimating()
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = false
        }
        
        if let vc = segue.destination as? ActionApprovedViewController {
            vc.action = sender as? RealmAction
        }
    }
    

}
