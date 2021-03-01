//
//  StudentClientConsumerNavigationController.swift
//  MyKey
//
//  Created by Dani Shifer on 1/20/20.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import UIKit
import MyKeyKit

open class StudentClientConsumerNavigationController: UINavigationController, StudentClientConsumer {
    var client: MyKeyStudentClient!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if var vc = self.topViewController as? StudentClientConsumer {
            vc.client = client
        }
    }
}
