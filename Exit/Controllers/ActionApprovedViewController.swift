//
//  ActionApprovedViewController.swift
//  MyKey
//
//  Created by Dani Shifer on 1/20/20.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import UIKit

class ActionApprovedViewController: UIViewController {

    var action: RealmAction!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLabel.text = ActionUI.time(format: "HH:mm", for: action)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        guard let vc = segue.destination as? ActionApprovedTableViewController else {
            fatalError("Invalid Child View Controller")
        }
        
        vc.action = action
    }
    

}
