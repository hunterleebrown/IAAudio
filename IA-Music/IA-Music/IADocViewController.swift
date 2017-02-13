//
//  IADocViewController.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/12/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit
import RealmSwift

class IADocViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var topView: UIView!
    @IBOutlet weak var docTitle: UILabel!
    @IBOutlet weak var etc: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    var audioFiles = [IAFileMappable]()
    let service = IAService()
    
    var identifier: String?
    var doc: IAArchiveDocMappable?
    
    var filesHash: [String:IAPlayerFile]?
    var notificationToken: NotificationToken? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 66
        
        // Do any additional setup after loading the view.
        
        if let ident = identifier {
            
            service.archiveDoc(identifier: ident, completion: { (inDoc, error) in
                self.doc = inDoc
                if let title = self.doc?.title {
                    self.docTitle.text = title
                    self.title = title
                }
                
                self.image.af_setImage(withURL: (self.doc!.iconUrl()))
                
                if let files = self.doc?.files {
                    self.audioFiles = files
                }
                
                self.tableView.reloadData()
                
                self.filesHash = IARealmManger.sharedInstance.filesOfArchive(identifier: ident)
            })
        }
        notificationToken = IARealmManger.sharedInstance.realm.addNotificationBlock { [weak self] notification, realm in
            self?.tableView.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doesPlayerFileExist(fileName:String)->Bool {
        if let hash = self.filesHash {
            return hash[fileName] != nil
        }
        return false
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as! IAAuidoFileTableViewCell
        let file = audioFiles[indexPath.row]
        cell.audioFile = file
        cell.archiveDoc = self.doc
        
        cell.addButton.isHidden = doesPlayerFileExist(fileName: file.name!)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = audioFiles[indexPath.row]
        if let theDoc = doc {
            IAPlayer.sharedInstance.playFile(file: file, doc: theDoc)
        }

    }
    
    deinit {
        notificationToken?.stop()
    }
    
}
