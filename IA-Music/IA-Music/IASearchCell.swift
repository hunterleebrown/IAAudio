//
//  IAMusicSearchCell.swift
//  IA Music
//
//  Created by Brown, Hunter on 11/19/15.
//  Copyright © 2015 Hunter Lee Brown. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage


class IASearchCell: UITableViewCell {
    
    @IBOutlet weak var itemImage : UIImageView?
    @IBOutlet weak var itemTitle : UILabel?
    @IBOutlet weak var creator : UILabel?
    @IBOutlet weak var dateLabel : UILabel?

    var searchDoc: IASearchDocMappable? {
        didSet {
            
            if let imageUrl = searchDoc?.iconUrl() {
                itemImage?.af_setImage(withURL:imageUrl)
                itemImage?.layer.cornerRadius = 10.0
                itemImage?.clipsToBounds = true
            }
            
            itemTitle?.text = searchDoc?.title
            
            if let cr = searchDoc?.displayCreator() {
                self.creator?.text = cr
                self.creator?.isHidden = false
            } else {
                self.creator?.isHidden = true
            }
            
            if let date = searchDoc?.displayContentDate() {
                if date.isEmpty {
                    self.dateLabel?.isHidden = true
                } else {
                    self.dateLabel?.isHidden = false
                    self.dateLabel?.text = date
                }
            } else {
                self.dateLabel?.isHidden = true
            }
            
        }
    
    }
    

    override func layoutSubviews() {
        self.backgroundColor = UIColor.clear
    }
    
    
    
}
