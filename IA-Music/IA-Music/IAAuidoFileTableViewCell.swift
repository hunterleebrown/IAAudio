//
//  IAAuidoFileTableViewCell.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/12/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit

class IAAuidoFileTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var length: UILabel!
    @IBOutlet weak var colorBackground: UIView!
    
    weak var audioFile: IAFileMappable? {
        didSet {
            titleLabel.text = audioFile?.title ?? audioFile?.name
            addButton.setIAIcon(.plusRound, forState: .normal)
            
            self.colorBackground.backgroundColor = isSelected ? UIColor.fairyCreamAlpha : UIColor.darkGray
            self.titleLabel.textColor = isSelected ? UIColor.fairyRed : UIColor.white
            
            if let l = audioFile?.displayLength {
                self.length.text = l
            }
        }
    }

    weak var archiveDoc: IAArchiveDocMappable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.colorBackground.backgroundColor = isSelected ? UIColor.fairyCreamAlpha : UIColor.darkGray

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.colorBackground.backgroundColor = selected ? UIColor.fairyCreamAlpha : UIColor.darkGray
        self.titleLabel.textColor = selected ? UIColor.fairyRed : UIColor.white
        self.addButton.setTitleColor(selected ? UIColor.fairyRed : UIColor.white, for: .normal)
        self.length.textColor = selected ? UIColor.fairyRed : UIColor.white

    }


    override func layoutSubviews() {
        super.layoutSubviews()
        self.colorBackground.backgroundColor = isSelected ? UIColor.fairyCreamAlpha : UIColor.darkGray
        self.addButton.setTitleColor(isSelected ? UIColor.fairyRed : UIColor.white, for: .normal)
        self.length.textColor = isSelected ? UIColor.fairyRed : UIColor.white
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear

    }
}
