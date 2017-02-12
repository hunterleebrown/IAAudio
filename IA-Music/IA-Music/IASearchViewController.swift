//
//  IASearchViewController.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/9/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit

class IASearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var searchResults = [IASearchDocMappable]()
    var filteredSearchResults = [IASearchDocMappable]()

    let searchController = UISearchController(searchResultsController: nil)
    
    let service = IAService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.darkGray
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["On The Internet Archive", "In Your Music Stash"]
        tableView.tableHeaderView = searchController.searchBar
        
        tableView.rowHeight = 90
        tableView.cellLayoutMarginsFollowReadableWidth = false

        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
//        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if searchController.isActive && searchController.searchBar.text != "" {
//            return filteredCandies.count
//        }
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! IASearchCell

        
        let result: IASearchDocMappable
//        if searchController.isActive && searchController.searchBar.text != "" {
//            result = filteredSearchResults[indexPath.row]
//        } else {
            result = searchResults[indexPath.row]
//        }
        
        cell.searchDoc = result
        return cell
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {

//        filteredSearchResults = searchResults.filter({( result : IAMapperDoc) -> Bool in
//            let categoryMatch = (scope == "All") || (candy.category == scope)
//            return categoryMatch && candy.name.lowercased().contains(searchText.lowercased())
//        })
        
        
        tableView.reloadData()
    }
    
    // MARK: - Segues
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "showDetail" {
    //            if let indexPath = tableView.indexPathForSelectedRow {
    //                let candy: Candy
    //                if searchController.isActive && searchController.searchBar.text != "" {
    //                    candy = filteredCandies[indexPath.row]
    //                } else {
    //                    candy = candies[indexPath.row]
    //                }
    //                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
    //                controller.detailCandy = candy
    //                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
    //                controller.navigationItem.leftItemsSupplementBackButton = true
    //            }
    //        }
    //    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemPush" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let result = searchResults[indexPath.row]
                let controller = segue.destination as! IADocViewController
                controller.searchDoc = result
            }
            
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchController.searchBar.resignFirstResponder()
    }
    
}


extension IASearchViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationController? .setNavigationBarHidden(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.navigationController? .setNavigationBarHidden(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        service.queryString = searchBar.text
        service.searchFetch { (contents, error) in
            
            if let contentItems = contents {
                self.searchResults = contentItems
                self.tableView.reloadData()
            }
   
        }
    }
    
}

extension IASearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        
    }
}



