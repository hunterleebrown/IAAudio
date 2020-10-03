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
    var searchController: UISearchController!
    
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
    
    func initSearchController(searchResultsController:UIViewController? = nil) {
        searchController = UISearchController(searchResultsController: searchResultsController)
        definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.tintColor = UIColor.fairyCream
        searchController.searchBar.backgroundColor = UIColor.clear
        searchController.searchBar.barTintColor = UIColor.clear
        searchController.searchBar.isTranslucent = true
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.scopeBarBackgroundImage = UIImage()
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = UIColor.fairyCream
            textField.backgroundColor = UIColor.clear
        }
    }
    
    func isSearching() -> Bool {
        guard searchController != nil else { return false }
        return searchController.isActive && searchController.searchBar.text != ""
    }
    


}


extension UINavigationBar {
    var titleColor: UIColor? {
        get {
            if let attributes = self.titleTextAttributes {
                return attributes[NSAttributedString.Key.foregroundColor] as? UIColor
            }
            return nil
        }
        set {
            if let value = newValue {
                self.titleTextAttributes = [NSAttributedString.Key.foregroundColor: value]
            }
        }
    }
    
    var titleFont: UIFont? {
        get {
            if let attributes = self.titleTextAttributes {
                return attributes[NSAttributedString.Key.font] as? UIFont
            }
            return nil
        }
        set {
            if let value = newValue {
                self.titleTextAttributes = [NSAttributedString.Key.font: value]
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
    
    func alert(title:String, message:String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle:UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.destructive, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.view.tintColor = IAColors.fairyRed
        self.present(alert, animated: true, completion: nil);
    
    }

    func alert(title:String, message:String?, completion:@escaping ()->Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle:UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            if(self.presentingViewController != nil) {
                alert.dismiss(animated: true, completion: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) -> Void in
            completion()
        }))
        
        alert.view.tintColor = IAColors.fairyRed
        self.present(alert, animated: true, completion: nil);
        
    }

    
}
