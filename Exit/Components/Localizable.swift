//
//  Localizable.swift
//  MyKey
//
//  Created by Haim Marcovici on 11/02/2020.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import UIKit

protocol Localizable {
    var localized: String { get }
}

extension String: Localizable {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

protocol XIBLocalizable {
    var localizationKey: String? { get set }
}

extension UILabel: XIBLocalizable {
    @IBInspectable var localizationKey: String? {
        get { return nil }
        set(key) {
            text = key?.localized
        }
    }
}

extension UIButton: XIBLocalizable {
    @IBInspectable var localizationKey: String? {
        get { return nil }
        set(key) {
            setTitle(key?.localized, for: .normal)
        }
    }
}

extension UINavigationItem: XIBLocalizable {
    @IBInspectable var localizationKey: String? {
        get { return nil }
        set(key) {
            title = key?.localized
        }
    }
}

extension UITabBarItem: XIBLocalizable {
    @IBInspectable var localizationKey: String? {
        get { return nil }
        set(key) {
            title = key?.localized
        }
    }
}

extension UITextField {
    @IBInspectable var placeholderLocalizationKey: String? {
        get { return nil }
        set(key) {
            placeholder = key?.localized
        }
    }
}
