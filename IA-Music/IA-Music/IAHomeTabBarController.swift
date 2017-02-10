//
//  IAHomeTabBarController.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/9/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit

class IAHomeTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let searchTab = self.tabBar.items![0] as UITabBarItem
        searchTab.setIAIcon(.iosSearch)
        
        let libraryTab = self.tabBar.items![1] as UITabBarItem
        libraryTab.setIAIcon(.iosMusicalNotes)
        
        let listTab = self.tabBar.items![2] as UITabBarItem
        listTab.setIAIcon(.iosListOutline)
        
        


        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    



}
