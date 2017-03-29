//
//  PlaylistViewController.swift
//  IAAudio
//
//  Created by Hunter Lee Brown on 3/25/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit

class PlaylistViewController: IAViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var playList: IAList?
    
    @IBOutlet weak var playListTitleInput: UITextField!
    
    @IBOutlet weak var playlistTable: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var searchBarHolder: UIView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var actionLabel: UILabel!
    
    var playlistFiles = [IAListFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let storyboard = UIStoryboard(name: "Playlist", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PlaylistFindTableViewController") as! PlaylistFindTableViewController
        controller.playListController = self
        let searchResultsController = controller
        
        self.initSearchController(searchResultsController:searchResultsController)
        self.searchController.searchBar.placeholder = "Find Tracks To Add"
        self.searchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        self.searchController.searchBar.frame = self.searchBarHolder.bounds
        self.searchController.searchResultsUpdater = searchResultsController
        self.searchBarHolder.addSubview(searchController.searchBar)
        
        
        playListTitleInput.tintColor = UIColor.fairyCream
        playListTitleInput.backgroundColor = UIColor.clear
        playListTitleInput.textColor = UIColor.fairyCream
        playListTitleInput.layer.borderColor = UIColor.fairyCream.cgColor
        playListTitleInput.layer.cornerRadius = 5.0
        playListTitleInput.layer.borderWidth = 1.0
        
        playListTitleInput.attributedPlaceholder =
            NSAttributedString(string: "Playlist Title",
                               attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        
        
        for button in [saveButton] {
            button?.setTitleColor(UIColor.fairyCream, for: .normal)
        }
        
        actionLabel.textColor = UIColor.fairyCream
        
        playlistTable.sectionFooterHeight = 0

        self.topTitle(text: "New Playlist")
        
        if let playL = playList {
            for file in playL.files.sorted(byKeyPath: "playlistOrder") {
                playlistFiles.append(file)
            }
            playlistTable.reloadData()
            playListTitleInput.text = playL.title
            self.topTitle(text: playL.title)
        }
        
        
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(PlaylistViewController.toggleEditMode(sender:)))
        
        self.navigationItem.rightBarButtonItem = rightButton
        rightButton.tintColor = UIColor.fairyCream
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)


    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearNavigation()
        super.viewWillAppear(animated)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func toggleEditMode(sender:UIBarButtonItem) {
        self.playlistTable.isEditing = !self.playlistTable.isEditing
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return playlistFiles.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stashCell", for: indexPath) as! IAMyStashTableViewCell
        cell.playlistFile = playlistFiles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }

    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            self.playlistFiles.remove(at: indexPath.row)
            self.playlistTable.deleteRows(at: [indexPath], with: .automatic)
            
            if playList != nil {
                self.savePlaylist()
            }
        
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.playlistFiles[sourceIndexPath.row]
        self.playlistFiles.remove(at: sourceIndexPath.row)
        self.playlistFiles.insert(movedObject, at: destinationIndexPath.row)
        
        if playList != nil {
            self.savePlaylist()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let pl = playList {
            IAPlayer.sharedInstance.playPlaylist(list: pl, start: indexPath.row)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        playListTitleInput.resignFirstResponder()
    }
    
    func appendPlaylistFile(playlistFile:IAListFile)->Bool {
        
        if !self.playlistFiles.contains( where: { $0.file.compoundKey == playlistFile.file.compoundKey }) {
            self.playlistFiles.append(playlistFile)
            self.playlistTable.reloadData()
            
            if playList != nil {
                self.savePlaylist()
            }
            
            return true
        }
        
        return false
    }
    
    
    @IBAction func savePlaylist() {

        if (playListTitleInput.text?.isEmpty)! {
            alert(title: "Playlist Title", message: "Titles must not be empty")
            return
        }
        print(self.playlistFiles)
        
        let title = self.playListTitleInput.text
        RealmManager.syncPlaylist(files: self.playlistFiles, title: title!, list: playList)
        displayActionMessage(message: "playlist saved")
    }

    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            animateKeyboardTray(amount: keyboardSize.height + 20 - (66 + 49)) //66 is the playerHeight and 49 is the tabBar height
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        animateKeyboardTray(amount:20)
    }
    
    func animateKeyboardTray(amount:CGFloat) {
        self.bottomLayoutConstraint.constant = amount

        UIView.animate(withDuration: 0.33, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    
    func displayActionMessage(message:String) {
    
        actionLabel.text = message
        
        UIView.animate(withDuration: 0.33, animations: { 
            self.actionLabel.alpha = 1.0
        }) { (complete) in
            
            UIView.animate(withDuration: 0.33, delay: 2.0, options: [], animations: {
                self.actionLabel.alpha = 0.0
            }, completion: nil)
        }
    
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}
