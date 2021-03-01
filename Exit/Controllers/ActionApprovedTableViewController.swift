//
//  ActionApprovedTableViewController.swift
//  MyKey
//
//  Created by Dani Shifer on 20/01/2020.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import UIKit

class ActionApprovedTableViewController: UITableViewController {
    
    var action: RealmAction!

    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var identifierLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        actionLabel.text = ActionUI.type(for: action)
        statusLabel.text = ActionUI.status(for: action)
        
        timeLabel.text = ActionUI.time(format: "HH:mm:ss", for: action)
        dateLabel.text = ActionUI.time(format: "dd MMMM yyyy", for: action)
        
        identifierLabel.text = "#\(action.id)"
        
        if let terminal = DataStore.shared.getTerminalMetadata(by: action.terminalId) {
            locationLabel.text = terminal.localizedName()
        } else {
            locationLabel.text = action.terminalId
        }
    }

}
