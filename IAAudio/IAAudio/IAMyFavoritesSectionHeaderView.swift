//
//  IAMyChoicesSectionHeaderView.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/19/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit

class IAMyFavoritesSectionHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func awakeFromNib() {
        
        if (title) != nil {
            title.textColor = UIColor.fairyCream
        }
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
    }
}
