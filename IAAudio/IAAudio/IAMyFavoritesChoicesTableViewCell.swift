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

            title.text = stashChoice.title

            if let choice = stashChoice {
                switch  choice {
                case .Archives:
                    fallthrough
                case .Lists:
                    choiceTypeIconLabel.font = UIFont(name: choiceTypeIconLabel.font.familyName, size: 40)
                    choiceTypeIconLabel.text =  stashChoice.iconLabelText
                case .Files:
                    choiceTypeIconLabel.setIAIcon(.document, iconSize: 44)

                }
            }

            self.isSelected ? showSelected() : showUnselected()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        choiceTypeIconLabel.text = nil
        title.text = nil
        subTitle.text = nil
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
