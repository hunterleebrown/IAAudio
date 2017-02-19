//
//  IATopNavView.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/18/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit

class IATopNavView: UIView {

    @IBOutlet weak var topNavViewTitle: UILabel!
    @IBOutlet weak var topNavViewSubTitle: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    

    override func awakeFromNib() {
        if let title = topNavViewTitle, let subtitle = topNavViewSubTitle {
            for label in [title, subtitle] {
                label.textColor = UIColor.fairyCream
            }
        }
    }
    
}
