//
//  PlaylistFindTableViewCell.swift
//  IAAudio
//
//  Created by Hunter Lee Brown on 3/25/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit

class PlaylistFindTableViewCell: UITableViewCell {

    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var archiveTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        for label in [trackTitle, archiveTitle] {
            label?.textColor = UIColor.fairyCream
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
