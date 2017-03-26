//
//  NowPlayingTableViewCell.swift
//  IAAudio
//
//  Created by Hunter Lee Brown on 3/25/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit

class NowPlayingTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        for label in [titleLabel, subTitleLabel] {
            label?.textColor = UIColor.fairyCream
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
