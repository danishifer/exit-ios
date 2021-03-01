//
//  StudentTabBarController.swift
//  MyKey
//
//  Created by Dani Shifer on 1/20/20.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import UIKit
import MyKeyKit

class StudentTabBarController: UITabBarController, StudentClientConsumer {
    
    var client: MyKeyStudentClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Inject client
        for tab in viewControllers ?? [] {
            if var vc = tab as? StudentClientConsumer {
                vc.client = client
            }
        }
    }
}
