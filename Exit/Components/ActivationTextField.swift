//
//  ActivationTextField.swift
//  MyKey
//
//  Created by Dani Shifer on 12/13/19.
//  Copyright © 2019 Dani Shifer. All rights reserved.
//

import UIKit

protocol ActivationTextFieldDelegate {
    func didDeleteOnEmpty(_ field: ActivationTextField)
}

class ActivationTextField: UITextField {
    var activationDelegate: ActivationTextFieldDelegate?
    
    override public func deleteBackward() {
        if text == "" {
            activationDelegate?.didDeleteOnEmpty(self)
        }
        
        super.deleteBackward()
    }
}
