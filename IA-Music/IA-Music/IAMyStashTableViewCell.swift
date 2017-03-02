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
    @IBOutlet weak var size: UILabel?
    @IBOutlet weak var length: UILabel?
    
    
    weak var archive: IAArchive? {
    
        didSet {
        
            if let title = trackTitle {
                title.text = archive?.title
                title.highlightedTextColor = UIColor.white
            }
            if let img = trackImage, let url = IAMediaUtils.imageUrlFrom((archive?.identifier)!) {
                img.af_setImage(withURL: url)
                img.layer.cornerRadius = 10.0
                img.clipsToBounds = true
            }
            
            if let track = itemTitle {
                track.text = archive?.creator
                track.highlightedTextColor = UIColor.white
            }
            
            if let download = downloadButton, let more = moreButton {
                download.isHidden = true
                more.isHidden = true
            }
            
            if let l = length {
                l.text = ""
            }
            isSelected ? showSelected() : showUnselected()

        }
    }
    
    weak var file: IAPlayerFile? {
        didSet {

            if let download = downloadButton, let more = moreButton {
                download.isHidden = false
                more.isHidden = false
            }

            
            if let title = trackTitle {
                title.text = (file?.title.isEmpty)! ? file?.name : file?.title
                title.highlightedTextColor = IAColors.fairyRed
            }
            
            if let archive = RealmManager.archives(identifier: (file?.archiveIdentifier)!).first {
                
                if let img = trackImage, let url = IAMediaUtils.imageUrlFrom(archive.identifier) {
                    img.af_setImage(withURL: url)
                    img.layer.cornerRadius = 3.0
                    img.clipsToBounds = true
                }
                
                if let track = itemTitle {
                    track.text = archive.title
                    track.highlightedTextColor = IAColors.fairyRed
                }
            }
            
            
            if let download = downloadButton, let f = file {
                if(!f.downloaded) {
                    download.setIAIcon(.iosCloudDownloadOutline, forState: UIControlState())
                    download.isHidden = false
                    download.isEnabled = true
                } else {
                    download.isEnabled = false
                    download.isHidden = false
                    download.setIAIcon(.document, forState: UIControlState())
                }
            }
            
            if let s = size, let value = file?.displaySize() {
                s.text = "\(value) mb"
            }

            if let l = length, let value = file?.displayLength() {
                l.text = value
            }
            self.accessoryType = .none

            isSelected ? showSelected() : showUnselected()

        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        self.contentView.backgroundColor = UIColor.fairyRed
        self.itemTitle?.textColor = UIColor.white
        
        if let more = moreButton {
            more.setIAIcon(.iosMoreOutline, forState: UIControlState())
            more.setTitleColor(UIColor.white, for: UIControlState())
            
        }
        
        if let push = pushButton {
            push.setTitleColor(UIColor.white, for: .normal)
            push.setIAIcon(.iosArrowForward, forState: .normal)
        }
        
        if let download = downloadButton {
            download.setTitleColor(UIColor.fairyCream, for: UIControlState())
        }
        

        
        self.tintColor = UIColor.fairyCream
    }
    
    func showSelected() {
        self.contentView.backgroundColor = UIColor.fairyCreamAlpha
        
        for label in [itemTitle, trackTitle, length, size] {
            if let lab = label {
                lab.textColor = UIColor.fairyRed
            }
        }
        
        for button in [downloadButton, moreButton] {
            if let b = button {
                b.setTitleColor(UIColor.fairyRed, for: .normal)
            }
        }
    }

    func showUnselected() {
        self.contentView.backgroundColor = UIColor.clear
        for label in [itemTitle, trackTitle, length, size] {
            if let lab = label {
                lab.textColor = UIColor.white
            }
        }
        
        for button in [downloadButton, moreButton] {
            if let b = button {
                b.setTitleColor(UIColor.fairyCream, for: .normal)
            }
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selected ? showSelected() : showUnselected()
    }
    

    
    
}
