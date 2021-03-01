//
//  ActionRejectedViewController.swift
//  MyKey
//
//  Created by Dani Shifer on 22/01/2020.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import UIKit

class ActionRejectedViewController: UIViewController {

    @IBOutlet weak var reasonLabel: UILabel!
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
