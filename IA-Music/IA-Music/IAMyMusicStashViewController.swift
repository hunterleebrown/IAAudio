//
//  IAMyMusicStashViewController.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/9/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit
import RealmSwift

enum StashMode {
    case SingleArchive
    case AllArchives
    case AllFiles
}

class IAMyMusicStashViewController: IAViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarHolder: UIView!
    
    @IBOutlet weak var archiveButtonsHolder: UIStackView!
    @IBOutlet weak var archiveButtonsHeight: NSLayoutConstraint!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var removeAllButton: UIButton!
    
    var leftTopButton: UIBarButtonItem!

    var identifier: String?
    var archives: Results<IAArchive>!
    var files: Results<IAPlayerFile>!
    
    var archiveFiles: Results<IAPlayerFile>!
    
    var notificationToken: NotificationToken? = nil
    
    var mode: StashMode = .AllArchives
    var numberOfRows = 0
    
    var filteredFiles: Results<IAPlayerFile>!
    var filteredArchives: Results<IAArchive>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.sectionFooterHeight = 0
        
        self.initSearchController()
        searchController.searchResultsUpdater = self
        
        
        switch mode {
        case .AllArchives:
            archives = RealmManager.archives()
            notificationToken = self.setUpNotification(mode: .AllArchives)
            self.topTitle(text: "All Archives")
            
            
        case .SingleArchive:
            archives = RealmManager.archives(identifier: identifier!)
            archiveFiles = RealmManager.defaultSortedFiles(identifier: identifier!)
            notificationToken = self.setUpNotification(mode: .SingleArchive)
            
            self.topTitle(text: (archives.first?.title)!)
            self.topSubTitle(text: (archives.first?.creator)!)
            
            let rightButton = UIBarButtonItem()
            rightButton.title = IAFontMapping.ARCHIVE
            rightButton.target = self
            rightButton.tag = 0;
            rightButton.action = #selector(IAMyMusicStashViewController.pushDoc(sender:))
            self.navigationItem.rightBarButtonItem = rightButton
            rightButton.tintColor = UIColor.fairyCream
            

        
        case .AllFiles:
            let realm = RealmManager.realm
            files = realm?.objects(IAPlayerFile.self).sorted(byKeyPath: "title")
            notificationToken = self.setUpNotification(mode: .AllFiles)
            self.topTitle(text: "All Files")
            

        }
        
        for button in [removeAllButton,detailsButton] {
            button?.setTitleColor(UIColor.fairyCream, for: .normal)
        }
        
        toggleArchvieButtons()
        tableView.tableFooterView = UIView()
        
        searchController.searchBar.frame = self.searchBarHolder.bounds
        self.searchBarHolder.addSubview(searchController.searchBar)
        
        self.tableView.tableHeaderView?.backgroundColor = UIColor.clear
        self.tableView.backgroundColor = UIColor.clear

    }

    
    func toggleArchvieButtons() {
        
        switch mode {
        case .AllFiles:
            fallthrough
        case .AllArchives:
            self.archiveButtonsHeight.constant = 0
            self.archiveButtonsHolder.isHidden = true
        case .SingleArchive:
            self.archiveButtonsHeight.constant = 44
            self.archiveButtonsHolder.isHidden = false
        }
    }

    func setUpNotification(mode:StashMode)->NotificationToken {
        
        switch mode {
        case .SingleArchive:
            
            return archiveFiles.addNotificationBlock({[weak self] (changes: RealmCollectionChange<Results<IAPlayerFile>>) in
                
                switch changes {
                case .initial:
                    self?.tableView.reloadData()
                case .update(let results, let deletions, let insertions, let modifications):
                    
                    if (self?.isSearching())!{
                        
                    } else {
                        
                        self?.tableView.beginUpdates()
                        self?.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        self?.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        self?.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        self?.tableView.endUpdates()
                    }
                    
                    if self?.archives.count == 0 {
                        self?.popIfCorrectController()
                    }
                    
                case .error(let error):
                    print (error)
                    break
                }
                
            })
            
        case .AllArchives:
            return archives.addNotificationBlock({[weak self] (changes: RealmCollectionChange<Results<IAArchive>>) in
                
                switch changes {
                case .initial:
                    self?.tableView.reloadData()
                case .update(let results, let deletions, let insertions, let modifications):
                    
                    if (self?.isSearching())! {
                        
                    } else {
                        
                        self?.tableView.beginUpdates()
                        self?.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        self?.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        self?.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        self?.tableView.endUpdates()
                    }
                    
                    if self?.archives.count == 0 {
                        self?.popIfCorrectController()
                    }
                    
                case .error(let error):
                    print (error)
                    break
                }
                
            })
        case .AllFiles:
            return files.addNotificationBlock({[weak self] (changes: RealmCollectionChange<Results<IAPlayerFile>>) in
                
                switch changes {
                case .initial:
                    self?.tableView.reloadData()
                case .update(let results, let deletions, let insertions, let modifications):
                    
                    
                    if (self?.isSearching())! {
                        
                    } else {
                        
                        self?.tableView.beginUpdates()
                        self?.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        self?.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        self?.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        self?.tableView.endUpdates()
                    }
                    
                    if results.count == 0 {
                        self?.popIfCorrectController()
                    }
                    
                case .error(let error):
                    print (error)
                    break
                }
                
            })
        }
    }
    
    
    func popIfCorrectController(){
        
        if (self.navigationController?.visibleViewController as? IAMyMusicStashViewController) != nil {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.clearNavigation()
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = self.tableView.indexPathForSelectedRow {
            let cell = self.tableView.cellForRow(at: indexPathForSelectedRow) as! IAMyStashTableViewCell
            if let file = cell.file {
                self.selectFileRowIfPlaying(indexPath: indexPathForSelectedRow, file: file)
            }
        }

        if notificationToken != nil {
            if mode == .AllArchives || mode == .SingleArchive{
                if archives.count == 0 || archives.isInvalidated {
                    self.popIfCorrectController()
                }
            }
            
            self.tableView.reloadData()
        }
        

        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch mode {
        case .AllArchives:
            
            return isSearching() ? filteredArchives.count : archives.count
            
        case .SingleArchive:
            
            if isSearching() {
                return filteredFiles.count
            }
            
            if let archive = archives.first {
                return archive.files.count
            } else {
                return 0
            }
        case .AllFiles:
            
            return isSearching() ? filteredFiles.count : files.count

        }
        
    }
    
    
    func pushDoc(sender:UIButton){
        self.performSegue(withIdentifier: "docPush", sender: sender)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch mode {
        case .AllArchives:
            let cell = tableView.dequeueReusableCell(withIdentifier: "archiveCell", for: indexPath) as! IAMyStashTableViewCell
            if let downloadButton = cell.downloadButton {
                downloadButton.removeTarget(self, action: #selector(IAMyMusicStashViewController.didPressDownloadButton(sender:)), for: .touchUpInside)
            }
            
            let archive = isSearching() ? filteredArchives[indexPath.row] : archives[indexPath.row]
            cell.archive = archive
            
            return cell
            
        case .SingleArchive:
            let cell = tableView.dequeueReusableCell(withIdentifier: "stashCell", for: indexPath) as! IAMyStashTableViewCell
            if let downloadButton = cell.downloadButton {
                downloadButton.removeTarget(self, action: #selector(IAMyMusicStashViewController.didPressDownloadButton(sender:)), for: .touchUpInside)
            }
            let file = isSearching() ? filteredFiles[indexPath.row] : archiveFiles[indexPath.row]
            cell.file = file
            cell.downloadButton?.tag = indexPath.row
            cell.downloadButton?.addTarget(self, action:#selector(IAMyMusicStashViewController.didPressDownloadButton(sender:)), for: .touchUpInside)
            self.selectFileRowIfPlaying(indexPath: indexPath, file: file)
            
            return cell

        case .AllFiles:
            let cell = tableView.dequeueReusableCell(withIdentifier: "stashCell", for: indexPath) as! IAMyStashTableViewCell
            if let downloadButton = cell.downloadButton {
                downloadButton.removeTarget(self, action: #selector(IAMyMusicStashViewController.didPressDownloadButton(sender:)), for: .touchUpInside)
            }
            let file = isSearching() ? filteredFiles[indexPath.row] : files[indexPath.row]
            cell.file = file
            cell.downloadButton?.tag = indexPath.row
            cell.downloadButton?.addTarget(self, action:#selector(IAMyMusicStashViewController.didPressDownloadButton(sender:)), for: .touchUpInside)
            self.selectFileRowIfPlaying(indexPath: indexPath, file: file)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch mode {
        case .SingleArchive:
            fallthrough
        case .AllFiles:
            return 76.0
        case .AllArchives:
            return 90.0
        }
    }

    func selectFileRowIfPlaying(indexPath:IndexPath, file:IAPlayerFile) {
    
        if let playUrl = IAPlayer.sharedInstance.playUrl {
            if file.urlString == playUrl.absoluteString {
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
        }
    }
    
    var chosenArchive: IAArchive?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch mode {
        case .SingleArchive:
            let file = isSearching() ? filteredFiles[indexPath.row] : archiveFiles[indexPath.row]
            IAPlayer.sharedInstance.playFile(file: file)
            
        case .AllFiles:
            let file = isSearching() ? filteredFiles[indexPath.row] : files[indexPath.row]
            IAPlayer.sharedInstance.playFile(file: file)
            
        case .AllArchives:
            chosenArchive = isSearching() ? filteredArchives[indexPath.row] : archives[indexPath.row]
            self.performSegue(withIdentifier: "archivePush", sender: nil)
        }
    }
    
    //MARK: - Editiing
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            
            switch mode {
            case .AllArchives:
                let archive: IAArchive!
                
                if isSearching() {
                    archive = filteredArchives[indexPath.row]
                    self.deleteAllFiles(archive: archive)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    archive = archives[indexPath.row]
                    self.deleteAllFiles(archive: archive)
                }
                
            case .SingleArchive:
                let file: IAPlayerFile!
                if isSearching() {
                    file = filteredFiles[indexPath.row]
                    RealmManager.deleteFile(file: file)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    file = archiveFiles[indexPath.row]
                    RealmManager.deleteFile(file: file)
                }
                print(file)
                
            case .AllFiles:
                let file: IAPlayerFile!
                if isSearching() {
                    file = filteredFiles[indexPath.row]
                    RealmManager.deleteFile(file: file)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    file = files[indexPath.row]
                    RealmManager.deleteFile(file: file)
                }
            }
            
        case .insert:
            break
        default:
            break
            
        }
    }
    
    @IBAction func didTapRemoveAllFiles(_ sender: Any) {
        if let archive = archives.first {
            self.deleteAllFiles(archive: archive)
        }
    }
    
    @IBAction func fullArchiveDetails(_ sender: Any) {
        if archives.first != nil {
            let button = sender as! UIButton
            button.tag = 0
            self.performSegue(withIdentifier: "docPush", sender: button)
        }
    }
    
    func deleteAllFiles(archive: IAArchive)  {
        if !archive.isInvalidated {
            RealmManager.deleteAllFiles(archive: archive)
        }
    }
    
    //MARK: -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "docPush" {
            
            var tag = 0
            
            if let button = sender as? UIButton {
                tag = button.tag
            }
            if let button = sender as? UIBarButtonItem {
                tag = button.tag
            }
            
            let archive = archives[tag]
            
            let controller = segue.destination as! IADocViewController
            controller.identifier = archive.identifier
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
        }
        
        if segue.identifier == "archivePush" {
            if let archive = chosenArchive {
                let controller = segue.destination as! IAMyMusicStashViewController
                controller.identifier = archive.identifier
                controller.mode = .SingleArchive
            }
        }
        

    }
    
    deinit {
        notificationToken?.stop()
    }
    
    
    // MARK: searching
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        
        switch mode {
        case .SingleArchive:
            let predicate = NSPredicate(format: "title CONTAINS[c] %@ OR name CONTAINS[c] %@", searchText, searchText)
            filteredFiles = archiveFiles.filter(predicate)
        case .AllFiles:
            let predicate = NSPredicate(format: "title CONTAINS[c] %@ OR name CONTAINS[c] %@", searchText, searchText)
            filteredFiles = files.filter(predicate)
        case .AllArchives:
            let predicate = NSPredicate(format: "title CONTAINS[c] %@", searchText)
            filteredArchives = archives.filter(predicate)
        }
        
        tableView.reloadData()
    }
    
    
    func didPressDownloadButton(sender:UIButton) {
        
        let file: IAPlayerFile!
        if isSearching() {
            file = filteredFiles[sender.tag]
        } else {
            
            switch mode {
            case .AllFiles:
                file = files[sender.tag]
            case .SingleArchive:
                file = archiveFiles[sender.tag]
            default:
                return
            }
            
        }

        switch file.sizeType {
        case .unknown:
            alert(title: "File size is unknown", message: "The size of this file is unkown. Download it anyway?", completion: { 
                RealmManager.downloadFile(playerFile: file)
            })
        case .appropriate:
            RealmManager.downloadFile(playerFile: file)
        case .large:
            alert(title: "File size is very large.", message: "This file is large at \(file.displaySize!) MB. It will take a long time to download. You have \(RealmManager.deviceRemainingFreeSpaceInBytes()!) MB remaining free. Download anyway?", completion: {
                RealmManager.downloadFile(playerFile: file)
            })
        }
        
        
    }
    
    
    
}


extension IAMyMusicStashViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

extension IAMyMusicStashViewController: UISearchBarDelegate {


}


