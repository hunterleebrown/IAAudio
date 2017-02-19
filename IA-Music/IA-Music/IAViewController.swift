//
//  IAViewController.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/18/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit


class IAViewController: UIViewController {
    
    //MARK: - Top Nav View
    @IBOutlet weak var topNavView: IATopNavView?
    
    func topTitle(text:String){
        if let navTitle = self.topNavView?.topNavViewTitle {
            navTitle.text = text
        }
    }
    
    func topSubTitle(text:String){
        if let navTitle = self.topNavView?.topNavViewSubTitle {
            navTitle.text = text
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        if let topNav = self.topNavView, self.navigationController != nil {
            topNav.frame = (self.navigationController?.navigationBar.bounds)!
            self.navigationItem.titleView = topNav
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension UINavigationBar {
    var titleColor: UIColor? {
        get {
            if let attributes = self.titleTextAttributes {
                return attributes[NSForegroundColorAttributeName] as? UIColor
            }
            return nil
        }
        set {
            if let value = newValue {
                self.titleTextAttributes = [NSForegroundColorAttributeName: value]
            }
        }
    }
    
    var titleFont: UIFont? {
        get {
            if let attributes = self.titleTextAttributes {
                return attributes[NSFontAttributeName] as? UIFont
            }
            return nil
        }
        set {
            if let value = newValue {
                self.titleTextAttributes = [NSFontAttributeName: value]
            }
        }
    }
}

extension UIViewController {
    
    func colorNavigation() {
        
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationController?.navigationBar.titleColor = UIColor.black
        
    }
    
    func clearNavigation() {
        
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = IAColors.fairyCream
        
    }
}
