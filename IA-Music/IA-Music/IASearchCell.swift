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

    
//    var _searchDoc : IASearchDoc!
    
//    var searchDoc : IASearchDoc! {
//        set {
//            _searchDoc = newValue
//            itemImage?.af_setImage(withURL:URL(string: _searchDoc.itemImageUrl)!)
//            itemTitle?.text = _searchDoc?.title
//            
//            itemTitle?.sizeToFit()
//            
//            itemTitle?.setNeedsLayout()
//            
//            if let cr = _searchDoc.creator {
//                self.creator?.text = "by \(cr)"
//                self.creator?.isHidden = false
//            } else {
//                self.creator?.isHidden = true
//
//            }
//            
//            
//            if let date = _searchDoc.date {
//                if !date.isEmpty {
//                    self.dateLabel?.text = StringUtils.shortDateFromDateString(date)
//                    self.dateLabel?.isHidden = false
//                } else {
//                    self.dateLabel?.isHidden = false
//                }
//            } else {
//                self.dateLabel?.isHidden = true
//            }
//
//            
//            
//        }
//        get {
//            return _searchDoc
//        }
//    
//    }
    
    var searchDoc: IASearchDocMappable? {
        didSet {
            
            if let imageUrl = searchDoc?.iconUrl() {
                itemImage?.af_setImage(withURL:imageUrl)
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
