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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    
    weak var audioFile: IAFileMappable? {
        didSet {
            nameLabel.text = audioFile?.name
            titleLabel.text = audioFile?.title
            addButton.setIAIcon(.plusRound, forState: .normal)
            
            print("--------------> track: \(audioFile?.cleanedTrack)")
        }
    }

    weak var archiveDoc: IAArchiveDocMappable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func didPressPlusButton(_ sender: Any) {
        if let file = audioFile, let doc = archiveDoc {
            IARealmManger.sharedInstance.addFile(docAndFile: (doc:doc, file:file))
        }
    }
}
