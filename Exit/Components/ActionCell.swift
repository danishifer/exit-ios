//
//  ActionCell.swift
//  MyKey
//
//  Created by Dani Shifer on 12/17/19.
//  Copyright © 2019 Dani Shifer. All rights reserved.
//

import UIKit
import PromiseKit

class ActionCell: UITableViewCell {

    @IBOutlet var icon: UIImageView!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

struct ActionCellData {
    var icon: UIImage?
    var type: String
    var location: String
    var time: String
    
    public static func from(action: RealmAction) -> ActionCellData {
        return ActionCellData(
            icon: ActionUI.icon(for: action),
            type: ActionUI.type(for: action),
            location: DataStore.shared.getTerminalMetadata(by: action.terminalId)?.localizedName() ?? action.terminalId,
            time: ActionUI.time(format: "HH:mm", for: action)
        )
    }
}
