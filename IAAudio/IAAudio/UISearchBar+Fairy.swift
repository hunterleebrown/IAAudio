//
//  UISearchBar+Fairy.swift
//  IAAudio
//
//  Created by Hunter Lee Brown on 3/25/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import Foundation
import UIKit

extension UISearchBar {

    func fairy() {
        
        self.tintColor = UIColor.fairyCream
        self.backgroundColor = UIColor.clear
        self.backgroundImage = UIImage()
        self.isTranslucent = true
        self.scopeBarBackgroundImage = UIImage()
        if let textField = self.value(forKey: "searchField") as? UITextField {
            textField.textColor = UIColor.fairyCream
        }
        
    }
}
