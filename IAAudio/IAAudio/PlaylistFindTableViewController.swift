//
//  PlaylistFindTableViewController.swift
//  IAAudio
//
//  Created by Hunter Lee Brown on 3/25/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit
import RealmSwift

class PlaylistFindTableViewController: UITableViewController  {

    
    var files: Results<IAPlayerFile>!
    var filteredFiles: Results<IAPlayerFile>!
    weak var playListController: PlaylistViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = RealmManager.realm
        files = realm?.objects(IAPlayerFile.self).sorted(byKeyPath: "title")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredFiles.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stashCell", for: indexPath) as! IAMyStashTableViewCell
        cell.file = filteredFiles[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = filteredFiles[indexPath.row]

        if let parentVC = playListController {
            let newPlaylistFile = IAListFile()
            newPlaylistFile.file = file
            
            if !parentVC.appendPlaylistFile(playlistFile: newPlaylistFile )  {
                self.alert(title: "Track already on Playlist", message: "\(newPlaylistFile.file.displayTitle) is already on the playlist")
            }
        }
    }




    
    
    // MARK: searching
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        let predicate = NSPredicate(format: "archiveTitle CONTAINS[c] %@ OR title CONTAINS[c] %@ OR name CONTAINS[c] %@", searchText, searchText, searchText)
        
        filteredFiles = files.filter(predicate)
        
        tableView.reloadData()
    }
    
}

extension PlaylistFindTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

