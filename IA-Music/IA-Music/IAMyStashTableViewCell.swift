//
//  IAMyStashTableViewCell.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/15/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit

class IAMyStashTableViewCell: UITableViewCell {
    
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    weak var file: IAPlayerFile? {
        didSet {
            trackTitle.text = file?.title
            itemTitle.text = file?.archive?.identifierTitle
            
            if let archive = file?.archive, let url = IAMediaUtils.imageUrlFrom(archive.identifier) {
                trackImage.af_setImage(withURL: url)
            }
            self.trackTitle.highlightedTextColor = IAColors.fairyRed
            
            
            if(file?.urlString.range(of: "http://") != nil) {
                downloadButton.setIAIcon(.iosCloudDownloadOutline, forState: UIControlState())
                downloadButton.isHidden = false
                downloadButton.isEnabled = true
            } else {
                downloadButton.isEnabled = false
                downloadButton.isHidden = false
                downloadButton.setIAIcon(.document, forState: UIControlState())
            }
            downloadButton.setTitleColor(IAColors.fairyRed, for: UIControlState())
            
            
            if moreButton != nil {
                moreButton.titleLabel?.font = UIFont(name: "Helvetica", size: 40.0)
                moreButton.setIAIcon(.iosMoreOutline, forState: UIControlState())
                moreButton.setTitleColor(IAColors.fairyRed, for: UIControlState())
                
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
