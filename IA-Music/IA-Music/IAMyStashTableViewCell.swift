//
//  IAMyStashTableViewCell.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/15/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit

class IAMyStashTableViewCell: UITableViewCell {
    
    @IBOutlet weak var trackTitle: UILabel?
    @IBOutlet weak var itemTitle: UILabel?
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var downloadButton: UIButton?
    @IBOutlet weak var moreButton: UIButton?
    @IBOutlet weak var pushButton: UIButton?
    
    
    weak var archive: IAArchive? {
    
        didSet {
        
            if let title = itemTitle {
                title.text = archive?.identifierTitle
                title.highlightedTextColor = IAColors.fairyRed
            }
            if let img = trackImage, let url = IAMediaUtils.imageUrlFrom((archive?.identifier)!) {
                img.af_setImage(withURL: url)
            }
            
            if let push = pushButton {
                push.setIAIcon(.iosArrowForward, forState: .normal)
                push.layer.cornerRadius = 3.0
                push.layer.borderColor = UIColor.lightGray.cgColor
                push.layer.borderWidth = 0.5
            }
        }
    }
    
    weak var file: IAPlayerFile? {
        didSet {
            
            if let title = itemTitle {
                title.text = (file?.title.isEmpty)! ? file?.name : file?.title
                title.text = file?.archive?.identifierTitle
                title.highlightedTextColor = IAColors.fairyRed
            }
            
            if let img = trackImage, let archive = file?.archive, let url = IAMediaUtils.imageUrlFrom(archive.identifier) {
                img.af_setImage(withURL: url)
            }
            
            if let track = trackTitle {
                track.text = file?.displayTitle()
                track.highlightedTextColor = IAColors.fairyRed
            }
            
            if let download = downloadButton {
                if(file?.urlString.range(of: "http://") != nil) {
                    download.setIAIcon(.iosCloudDownloadOutline, forState: UIControlState())
                    download.isHidden = false
                    download.isEnabled = true
                } else {
                    download.isEnabled = false
                    download.isHidden = false
                    download.setIAIcon(.document, forState: UIControlState())
                }
                download.setTitleColor(IAColors.fairyRed, for: UIControlState())
            }
            
            
            if let more = moreButton {
                more.titleLabel?.font = UIFont(name: "Helvetica", size: 40.0)
                more.setIAIcon(.iosMoreOutline, forState: UIControlState())
                more.setTitleColor(IAColors.fairyRed, for: UIControlState())
                
            }
            
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.contentView.backgroundColor = selected ? IAColors.fairyCream : UIColor.white
    }
    

    
    
}
