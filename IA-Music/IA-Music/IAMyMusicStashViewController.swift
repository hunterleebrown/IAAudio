//
//  IAMyMusicStashViewController.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/9/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit
import RealmSwift

class IAMyMusicStashViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var realm: Realm?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarHolder: UIView!
    
    var archives: Results<IAArchive>!
    var notificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Music Stash"
        
        tableView.rowHeight = 54
        tableView.sectionHeaderHeight = 54
        tableView.sectionFooterHeight = 27

        self.colorNavigation()
        
        realm = IARealmManger.sharedInstance.realm
        archives = realm?.objects(IAArchive.self).sorted(byKeyPath: "identifierTitle")
        
        notificationToken = realm?.addNotificationBlock { [weak self] notification, realm in
            self?.tableView.reloadData()
        }
        
        self.navigationController?.navigationBar.titleColor = IAColors.fairyCream

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleColor = IAColors.fairyCream
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return archives.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let archive = archives[section]
        return archive.files.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let archive = archives[section]
        return archive.identifierTitle
    }
    
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            return UIView()
    }
    
    
    
    func pushDoc(sender:UIButton){
        self.performSegue(withIdentifier: "docPush", sender: sender)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stashCell", for: indexPath) as! IAMyStashTableViewCell
       
        let archive = archives[indexPath.section]
        if let file = IARealmManger.sharedInstance.defaultSortedFiles(identifier: archive.identifier)?[indexPath.row] {
            cell.file = file
        }
        
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let archive = archives[indexPath.section]
        if let file = IARealmManger.sharedInstance.defaultSortedFiles(identifier: archive.identifier)?[indexPath.row] {
            IAPlayer.sharedInstance.playFile(file: file)
        }
        
        
    }
    
    
    //MARK: - Editiing
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            self.deleteFile(indexPath: indexPath)
            break
        case .insert:
            break
        default:
            break
            
        }
        
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
    
    
    //MARK: -
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let button = sender as? UIButton {
            let archive = archives[button.tag]
            if segue.identifier == "docPush" {
                let controller = segue.destination as! IADocViewController
                controller.identifier = archive.identifier
            }
        }
        

    }
    
    
    
}



