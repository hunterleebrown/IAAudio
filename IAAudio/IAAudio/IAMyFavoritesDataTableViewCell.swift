//
//  IAMyChoicesDetailsTableViewCell.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/19/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit

class IAMyFavoritesDataTableViewCell: IAMyFavoritesSectionHeaderTableViewCell {

    @IBOutlet weak var numberOfDownloadedFiles: UILabel!
    @IBOutlet weak var diskSpaceUsage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
