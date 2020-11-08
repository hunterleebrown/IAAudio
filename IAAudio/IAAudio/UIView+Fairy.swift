//
//  UIView+Fairy.swift
//  IAAudio
//
//  Created by Hunter Lee Brown on 3/25/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    func fairy() {
        
        self.tintColor = UIColor.fairyCream
        self.backgroundColor = UIColor.clear

        if let searchBar = self as? UISearchBar {
            searchBar.backgroundImage = UIImage()
            searchBar.isTranslucent = true
            searchBar.scopeBarBackgroundImage = UIImage()
            if let textField = searchBar.value(forKey: "searchField") as? UITextField {
                textField.textColor = UIColor.fairyCream
            }
        }

        if let activityInidcator = self as? UIActivityIndicatorView {
            activityInidcator.color = UIColor.fairyCream
            activityInidcator.style = .large
        }
        
    }
}


