//
//  FadeSegue.swift
//  MyKey
//
//  Created by Dani Shifer on 1/20/20.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import UIKit

class FadeSegue: UIStoryboardSegue {
    
    override func perform() {
        UIView.transition(with: source.navigationController!.view, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.source.navigationController?.pushViewController(self.destination, animated: false)
        }, completion: nil)
    }
}
