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
        
        tableView.rowHeight = 60
        
        realm = IARealmManger.sharedInstance.realm
        archives = realm?.objects(IAArchive.self).sorted(byKeyPath: "identifierTitle")
        
        notificationToken = realm?.addNotificationBlock { [weak self] notification, realm in
            self?.tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(IAMyMusicStashViewController.didPressDocTitle),
            name: NSNotification.Name(rawValue: "pushDoc"),
            object: nil
        )
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
       
        let archive = archives[indexPath.section]
        let file = archive.files[indexPath.row]
        
        cell.detailTextLabel?.text = file.archive?.identifierTitle
        cell.textLabel?.text = file.displayTitle()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = archives[indexPath.section].files[indexPath.row]
        IAPlayer.sharedInstance.playFile(file: file)
    }
    
    
    func didPressDocTitle() {
        if IAPlayer.sharedInstance.fileIdentifier != nil {
            self.performSegue(withIdentifier: "docPush", sender: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "minimizePlayer"), object: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "docPush" {
            let doc = segue.destination as! IADocViewController
            doc.identifier = IAPlayer.sharedInstance.fileIdentifier
        }
    }
    
    
    
}



