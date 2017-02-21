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
    
    
    
    func setUpNotification(mode:StashMode)->NotificationToken {
    
        switch mode {
        case .SingleArchive:
            
            return archiveFiles.addNotificationBlock({[weak self] (changes: RealmCollectionChange<Results<IAPlayerFile>>) in
                
                switch changes {
                case .initial:
                    self?.tableView.reloadData()
                case .update(let results, let deletions, let insertions, let modifications):
                    self?.tableView.beginUpdates()
                    self?.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    self?.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    self?.tableView.endUpdates()
                    
                    if self?.archives.count == 0 {
                        self?.navigationController?.popViewController(animated: true)
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
                    self?.tableView.beginUpdates()
                    self?.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    self?.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    self?.tableView.endUpdates()
                    
                    if self?.archives.count == 0 {
                        self?.navigationController?.popViewController(animated: true)
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
                    self?.tableView.beginUpdates()
                    self?.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    self?.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    self?.tableView.endUpdates()
                    
                    if results.count == 0 {
                        self?.navigationController?.popViewController(animated: true)
                    }
                    
                case .error(let error):
                    print (error)
                    break
                }
                
            })
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.sectionFooterHeight = 0
        
        switch mode {
        case .AllArchives:
            archives = IARealmManger.sharedInstance.archives()
            notificationToken = self.setUpNotification(mode: .AllArchives)
            self.topTitle(text: "All Archives")
            
        case .SingleArchive:
            archives = IARealmManger.sharedInstance.archives(identifier: identifier!)
            archiveFiles = IARealmManger.sharedInstance.defaultSortedFiles(identifier: identifier!)
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
            let realm = IARealmManger.sharedInstance.realm
            files = realm?.objects(IAPlayerFile.self).sorted(byKeyPath: "title")
            notificationToken = self.setUpNotification(mode: .AllFiles)
            self.topTitle(text: "All Files")

        }
        
        for button in [removeAllButton,detailsButton] {
            button?.setTitleColor(UIColor.fairyCream, for: .normal)
        }
        
        toggleArchvieButtons()
        tableView.tableFooterView = UIView()

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
            if mode == .AllArchives {
                if archives.count == 0 {
                    self.navigationController?.popViewController(animated: true)
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
            return archives.count
        case .SingleArchive:
            if let archive = archives.first {
                return archive.files.count
            } else {
                return 0
            }
        case .AllFiles:
            return files.count
        }
        
    }
    
    
    func pushDoc(sender:UIButton){
        self.performSegue(withIdentifier: "docPush", sender: sender)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch mode {
        case .AllArchives:
            let cell = tableView.dequeueReusableCell(withIdentifier: "archiveCell", for: indexPath) as! IAMyStashTableViewCell
            cell.archive = archives[indexPath.row]
            
            return cell
            
        case .SingleArchive:
            let cell = tableView.dequeueReusableCell(withIdentifier: "stashCell", for: indexPath) as! IAMyStashTableViewCell
            let file = archiveFiles[indexPath.row]
            cell.file = file
            self.selectFileRowIfPlaying(indexPath: indexPath, file: file)
            
            return cell

        case .AllFiles:
            let cell = tableView.dequeueReusableCell(withIdentifier: "stashCell", for: indexPath) as! IAMyStashTableViewCell
            let file = files[indexPath.row]
            cell.file = files[indexPath.row]
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
            let file = archiveFiles[indexPath.row]
            IAPlayer.sharedInstance.playFile(file: file)
            
        case .AllFiles:
            let file = files[indexPath.row]
            IAPlayer.sharedInstance.playFile(file: file)
            
        case .AllArchives:
            chosenArchive = archives[indexPath.row]
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
                let archive = archives[indexPath.row]
                self.deleteAllFiles(archive: archive)
                
            case .SingleArchive:
                let file = archiveFiles[indexPath.row]
                print(file)
                IARealmManger.sharedInstance.deleteFile(file: file)
                
            case .AllFiles:
                let file = files[indexPath.row]
                IARealmManger.sharedInstance.deleteFile(file: file)
            }
            
        case .insert:
            break
        default:
            break
            
        }
    }
    
    @IBAction func didTapRemoveAllFiles(_ sender: Any) {
        self.deleteAllFiles(archive: archives.first!)
    }
    
    @IBAction func fullArchiveDetails(_ sender: Any) {
        let button = sender as! UIButton
        button.tag = 0
        self.performSegue(withIdentifier: "docPush", sender: button)
    }
    
    
    
    func deleteAllFiles(archive: IAArchive)  {
        IARealmManger.sharedInstance.deleteAllFiles(archive: archive)
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
    
    
}



