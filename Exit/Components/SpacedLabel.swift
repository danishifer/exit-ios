//
//  SpacedLabel.swift
//  MyKey
//
//  Created by Dani Shifer on 13/12/2019.
//  Copyright © 2019 Dani Shifer. All rights reserved.
//

import UIKit

@IBDesignable
open class SpacedLabel: UILabel {
    @IBInspectable open var characterSpacing: CGFloat = 1 {
        didSet {
            let attributedString = NSMutableAttributedString(string: self.text!)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: self.characterSpacing, range: NSRange(location: 0, length: attributedString.length))
            self.attributedText = attributedString
        }

    }
}
