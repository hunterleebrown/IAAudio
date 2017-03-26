//
//  IASearchViewController.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/9/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit

class IASearchViewController: IAViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResults = [IASearchDocMappable]()
    
    let service = IAService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 90
        tableView.cellLayoutMarginsFollowReadableWidth = false
        
        searchBar.fairy()

        if let topNav = topNavView {
            topNav.topNavViewTitle.text = "Search For Audio"
            topNav.topNavViewSubTitle.text = "On The Internet Archive"
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.clearNavigation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! IASearchCell
        
        let result: IASearchDocMappable
        result = searchResults[indexPath.row]
        
        cell.searchDoc = result
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushDoc" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let result = searchResults[indexPath.row]
                let controller = segue.destination as! IADocViewController
                controller.identifier = result.identifier
                controller.searchDoc = result
                let backItem = UIBarButtonItem()
                backItem.title = ""
                navigationItem.backBarButtonItem = backItem
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
}


extension IASearchViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        service.queryString = searchBar.text
        service.searchFetch { (contents, error) in
            
            if let contentItems = contents {
                self.searchResults = contentItems
                self.tableView.reloadData()
            }
   
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        guard IAReachability.isConnectedToNetwork() else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "networkAlert"), object: nil)
            return
        }
        
    }
    
}





