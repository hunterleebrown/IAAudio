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
    
    var mode: StashMode!
    
    weak var archive: IAArchive? {
    
        didSet {
        
            mode = .archive
            
            if let title = trackTitle {
                title.text = archive?.identifierTitle
                title.highlightedTextColor = UIColor.white
            }
            if let img = trackImage, let url = IAMediaUtils.imageUrlFrom((archive?.identifier)!) {
                img.af_setImage(withURL: url)
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

            mode = .song

            if let download = downloadButton, let more = moreButton {
                download.isHidden = false
                more.isHidden = false
            }

            
            if let title = trackTitle {
                title.text = (file?.title.isEmpty)! ? file?.name : file?.title
//                title.text = file?.archive?.identifierTitle
                title.highlightedTextColor = IAColors.fairyRed
            }
            
            if let img = trackImage, let archive = file?.archive, let url = IAMediaUtils.imageUrlFrom(archive.identifier) {
                img.af_setImage(withURL: url)
            }
            
            if let track = itemTitle {
                track.text = file?.archive?.identifierTitle
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
