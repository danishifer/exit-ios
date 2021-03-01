//
//  WelcomeViewController.swift
//  MyKey
//
//  Created by Dani Shifer on 12/11/19.
//  Copyright © 2019 Dani Shifer. All rights reserved.
//

import UIKit

public class WelcomeViewController: UIViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        
        // Remove navigation bar border
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    

    
    // MARK: - Navigation
//    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }
    

}
