//
//  IAMyStashChoicesTableViewCell.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/19/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit

class IAMyFavoritesChoicesTableViewCell: UITableViewCell {

    @IBOutlet weak var choiceTypeIconLabel: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    var stashChoice: StashChoice! {
        didSet {
            if let tit = title {
                tit.text = stashChoice?.title
            }
            if let icon = choiceTypeIconLabel {
                if let choice = stashChoice {
                    switch  choice {
                    case .Archives:
                        fallthrough
                    case .Lists:
                        icon.font = UIFont(name: icon.font.familyName, size: 40)
                        icon.text =  stashChoice.iconLabelText
                    case .Files:
                        icon.setIAIcon(.document, iconSize: 44)
                        
                    }
                }
            }
            
            self.isSelected ? showSelected() : showUnselected()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }



    
    func showSelected() {
        self.backgroundColor = UIColor.fairyCream
        self.tintColor = UIColor.fairyRed
        
        for label in [title, subTitle] {
            if let lab = label {
                lab.textColor = UIColor.fairyRed
            }
        }
    }
    
    func showUnselected() {
        self.backgroundColor = UIColor.clear
        self.tintColor = UIColor.white

        for label in [title,subTitle] {
            if let lab = label {
                lab.textColor = UIColor.white
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        selected ? showSelected() : showUnselected()
    }
    
}
