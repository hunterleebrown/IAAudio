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
        
        self.tabBar.barTintColor = UIColor.fairyRed
        
        self.tabBar.tintColor = IAColors.fairyCream
        self.tabBar.unselectedItemTintColor = UIColor.black
        
        
        let libraryTab = self.tabBar.items![0] as UITabBarItem
        libraryTab.setIAIcon(.iosMusicalNotes)
        
        let searchTab = self.tabBar.items![1] as UITabBarItem
        searchTab.setIAIcon(.iosSearch)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(IAHomeTabBarController.didPressDocTitle),
            name: NSNotification.Name(rawValue: "pushDoc"),
            object: nil
        )
        
        self.clearNavigation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "docPush" {
            let nav = segue.destination as! UINavigationController
            let doc =  nav.viewControllers.first as! IADocViewController
            doc.identifier = IAPlayer.sharedInstance.fileIdentifier
            
            
            if doc.navigationItem.leftBarButtonItem == nil {
                let button = UIBarButtonItem(barButtonSystemItem: .done, target: doc, action: #selector(doc.dismissViewController))
                doc.navigationItem.leftBarButtonItem = button
            }
        }
    }
    
    
    func didPressDocTitle() {
        if IAPlayer.sharedInstance.fileIdentifier != nil {
            self.performSegue(withIdentifier: "docPush", sender: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "minimizePlayer"), object: nil)
        }
    }
    
    
}
