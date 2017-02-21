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
    case song
    case archive
}

class IAMyMusicStashViewController: IAViewController, UITableViewDelegate, UITableViewDataSource {
    
    var realm: Realm?

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
    var notificationToken: NotificationToken? = nil
    
    var mode: StashMode = .archive
    var numberOfRows = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.sectionHeaderHeight = 54
        tableView.sectionFooterHeight = 0
        
        realm = IARealmManger.sharedInstance.realm
        if let ident = identifier {
            archives = IARealmManger.sharedInstance.archives(identifier: ident)

        } else {
            archives = IARealmManger.sharedInstance.archives()
        }
        
        files = realm?.objects(IAPlayerFile.self).sorted(byKeyPath: "title")
        
        notificationToken = realm?.addNotificationBlock { [weak self] notification, realm in
            self?.tableView.reloadData()
            self?.toggleArchvieButtons()
        }
        
        
        if archives.count > 1 {
            self.topTitle(text: "Archives")
//            self.leftTopButton = UIBarButtonItem()
//            self.leftTopButton.title = mode == .song ? "Songs" : "Archives"
//            self.leftTopButton.target = self
//            self.leftTopButton.action = #selector(modeSwitch(sender:))
//            self.navigationItem.leftBarButtonItem = self.leftTopButton
//            self.leftTopButton.tintColor = UIColor.fairyCream
        }
        
        if archives.count == 1 {
            self.topTitle(text: (archives.first?.identifierTitle)!)
            self.topSubTitle(text: (archives.first?.creator)!)
            let rightButton = UIBarButtonItem()
            rightButton.title = IAFontMapping.ARCHIVE
            
//            rightButton.title = "Details"
//            rightButton.setIAIcon(.archive, iconSize: 44.0)
            
            rightButton.target = self
            rightButton.tag = 0;
            rightButton.action = #selector(IAMyMusicStashViewController.pushDoc(sender:))
            self.navigationItem.rightBarButtonItem = rightButton
            rightButton.tintColor = UIColor.fairyCream
        }
        
        for button in [removeAllButton,detailsButton] {
            button?.setTitleColor(UIColor.fairyCream, for: .normal)
        }
        
        if mode == .song {
            self.topTitle(text: "All Files")
        }
        
        toggleArchvieButtons()
        
        tableView.tableFooterView = UIView()

    }

    
    func toggleArchvieButtons() {
        if mode == .song {
            self.archiveButtonsHeight.constant = 0
            self.archiveButtonsHolder.isHidden = true
        } else {
            if archives.count == 1 {
                self.archiveButtonsHeight.constant = 44
                self.archiveButtonsHolder.isHidden = false
            } else {
                self.archiveButtonsHeight.constant = 0
                self.archiveButtonsHolder.isHidden = true
            }
        }
    }


    func modeSwitch(sender:UIBarButtonItem){
        switch mode {
        case .song:
            mode = .archive
            self.leftTopButton.title = "Archives"
        case .archive:
            mode = .song
            self.leftTopButton.title = "Files"
        }
        
        self.tableView.reloadData()
        toggleArchvieButtons()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearNavigation()
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = self.tableView.indexPathForSelectedRow {
            let cell = self.tableView.cellForRow(at: indexPathForSelectedRow) as! IAMyStashTableViewCell
//            self.tableView.deselectRow(at: indexPathForSelectedRow, animated: false)
            if let file = cell.file {
                self.selectFileRowIfPlaying(indexPath: indexPathForSelectedRow, file: file)
            }
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
        
        switch mode {
        case .archive:
            return archives.count
        case .song:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch mode {
        case .archive:
            return 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch mode {
        case .song:
            return files.count
        case .archive:
            
            if archives.count == 1 {
                return (archives.first?.files.count)!
            } else {
                return archives.count
            }

        }
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let archive = archives[section]
//        return archive.identifierTitle
//    }
    
    func  tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! IAMyStashTableViewCell
        let archive = archives[section]
        cell.archive = archive

        if let pushButton = cell.pushButton {
            pushButton.tag = section
            pushButton.addTarget(self, action:#selector(IAMyMusicStashViewController.pushDoc(sender:)), for: .touchUpInside)
        }
        
        return cell.contentView
    }
    
    
    
    
    func pushDoc(sender:UIButton){
        self.performSegue(withIdentifier: "docPush", sender: sender)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

       
        switch mode {
        case .song:
        let cell = tableView.dequeueReusableCell(withIdentifier: "stashCell", for: indexPath) as! IAMyStashTableViewCell
            let file = files[indexPath.row]
            cell.file = file
            self.selectFileRowIfPlaying(indexPath: indexPath, file: file)
            return cell
        case .archive:
            if archives.count == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "stashCell", for: indexPath) as! IAMyStashTableViewCell
                let archive = archives[indexPath.section]
                let file = IARealmManger.sharedInstance.defaultSortedFiles(identifier: archive.identifier)?[indexPath.row]     //archive.files[indexPath.row]
                cell.file = file
                self.selectFileRowIfPlaying(indexPath: indexPath, file: file!)
                return cell

            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "archiveCell", for: indexPath) as! IAMyStashTableViewCell
                let archive = archives[indexPath.row]
                cell.archive = archive
                return cell
            }
        }
        
//        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch  mode {
        case .song:
            return 76.0
        case .archive:
            if archives.count == 1 {
                return 76.0
            } else {
                return 90.0
            }
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
        case .archive:
            if archives.count == 1 {
                let archive = archives[indexPath.section]
                let file = IARealmManger.sharedInstance.defaultSortedFiles(identifier: archive.identifier)?[indexPath.row]
                IAPlayer.sharedInstance.playFile(file: file!)
            } else {
                chosenArchive = archives[indexPath.row]
                self.performSegue(withIdentifier: "archivePush", sender: nil)
            }
            
            break
        case .song:
            let file = files[indexPath.row]
            IAPlayer.sharedInstance.playFile(file: file)

        }
        
    }
    
    
    //MARK: - Editiing
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return archives.count == 1 ? true : mode == .song ? true : true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            if mode == .song {
                let file = files[indexPath.row]
                IARealmManger.sharedInstance.realm.delete(file)
            } else {
                if archives.count > 1 {
                    let archive = archives[indexPath.row]
                    self.deleteAllFiles(archive: archive)
                } else {
                    deleteFile(indexPath: indexPath)
                }
            }
            break
        case .insert:
            break
        default:
            break
            
        }
        if archives.count == 0 {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func didTapRemoveAllFiles(_ sender: Any) {
        self.deleteAllFiles(archive: archives.first!)
        if archives.count == 0 {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func fullArchiveDetails(_ sender: Any) {
        let button = sender as! UIButton
        button.tag = 0
        self.performSegue(withIdentifier: "docPush", sender: button)
    }
    
    
    func deleteFile(indexPath:IndexPath)  {
        let archive = archives[indexPath.section]
        
        if let file = IARealmManger.sharedInstance.defaultSortedFiles(identifier: archive.identifier)?[indexPath.row] {
            try! IARealmManger.sharedInstance.realm.write {
                IARealmManger.sharedInstance.realm.delete(file)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            let files = archive.files
            if files.count == 0 {
                try! IARealmManger.sharedInstance.realm.write {
                    IARealmManger.sharedInstance.realm.delete(archive)
                }
            }
        }
    }
    
    func deleteAllFiles(archive: IAArchive)  {
        
        for file in IARealmManger.sharedInstance.defaultSortedFiles(identifier: archive.identifier)! {
            try! IARealmManger.sharedInstance.realm.write {
                IARealmManger.sharedInstance.realm.delete(file)
            }
        }
        
        let files = archive.files
        if files.count == 0 {
            try! IARealmManger.sharedInstance.realm.write {
                IARealmManger.sharedInstance.realm.delete(archive)
            }
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
                controller.mode = .archive
            }
        }
        

    }
    
    
    
}



