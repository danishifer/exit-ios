//
//  RoundedView.swift
//  MyKey
//
//  Created by Dani Shifer on 12/13/19.
//  Copyright © 2019 Dani Shifer. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }


}

