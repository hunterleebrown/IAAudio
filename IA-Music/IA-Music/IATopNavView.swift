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
    @IBOutlet weak var titleStackView: UIStackView!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    

    override func awakeFromNib() {
        
        if let stack = titleStackView {
            stack.alignment = .center
            stack.distribution = .fillProportionally
            stack.spacing = 1.0
        }
        
        if let title = topNavViewTitle, let subtitle = topNavViewSubTitle {
            title.font = UIFont.preferredFont(forTextStyle: .caption1)
            subtitle.font = UIFont.preferredFont(forTextStyle: .caption2)
            
//            title.pinn
            
            for label in [title, subtitle] {
                label.textColor = UIColor.fairyCream
                label.numberOfLines = 1
            }
        }
    }
    
}
