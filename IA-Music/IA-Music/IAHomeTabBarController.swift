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

        let searchTab = self.tabBar.items![2] as UITabBarItem
        searchTab.setIAIcon(.iosSearch)
        
        let libraryTab = self.tabBar.items![0] as UITabBarItem
        libraryTab.setIAIcon(.iosMusicalNotes)
        
        let listTab = self.tabBar.items![1] as UITabBarItem
        listTab.setIAIcon(.iosListOutline)
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(IAHomeTabBarController.didPressDocTitle),
            name: NSNotification.Name(rawValue: "pushDoc"),
            object: nil
        )


        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "docPush" {
            let doc = segue.destination as! IADocViewController
            doc.identifier = IAPlayer.sharedInstance.fileIdentifier
        }
    }
    
    
    func didPressDocTitle() {
        if IAPlayer.sharedInstance.fileIdentifier != nil {
            self.performSegue(withIdentifier: "docPush", sender: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "minimizePlayer"), object: nil)
        }
    }
    
    
}
