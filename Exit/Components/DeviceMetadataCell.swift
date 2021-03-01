//
//  DeviceMetadataCell.swift
//  MyKey
//
//  Created by Dani Shifer on 2/6/20.
//  Copyright © 2020 Dani Shifer. All rights reserved.
//

import UIKit

class DeviceMetadataCell: UITableViewCell {
    
    @IBOutlet var icon: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
