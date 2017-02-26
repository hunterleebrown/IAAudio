//
//  IADocViewController.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/12/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit
import RealmSwift

class IADocViewController: IAViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet var topView: UIView!
    @IBOutlet weak var topViewTopContraint: NSLayoutConstraint!
    
    @IBOutlet weak var docTitle: UILabel!
    @IBOutlet weak var docDeets: UILabel!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var imageExpand: UIButton!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var addAllButton: UIButton!
    
    var audioFiles = [IAFileMappable]()
    let service = IAService()
    
    var identifier: String?
    var doc: IAArchiveDocMappable?
    var searchDoc: IASearchDocMappable?
    
    var notificationToken: NotificationToken? = nil
    var archive: IAArchive?
    
    var forcedShowNavigationBar = false
    
    var filesNameInRealm: [String:IAPlayerFile?] = [String:IAPlayerFile?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView?.tableFooterView = UIView(frame: CGRect.zero)
        self.activityIndicatorView.color = IAColors.fairyRed
        self.activityIndicatorView.startAnimation()
        self.tableView.backgroundColor = UIColor.clear
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        //MARK: - Top Nav View Setting
        if let sDoc = searchDoc {
            self.topTitle(text: sDoc.title!)
            if let creator = sDoc.displayCreator() {
                self.topSubTitle(text: creator)
            }
        }
        //MARK: -
        
        if let ident = identifier {
            
            
            service.archiveDoc(identifier: ident, completion: { (inDoc, error) in
                self.doc = inDoc
                
                if self.searchDoc == nil, let doc = self.doc {
                    if let topNavView = self.topNavView {
                        topNavView.topNavViewTitle.text = doc.title
                            if let creator = doc.creator {
                                topNavView.topNavViewSubTitle.text = creator
                            }
                    }
                }
                
                if let deets = self.docDeets {
                    if let rawHtml = self.doc?.rawDescription() {
                        // let stripped = rawHtml.removeAttribute(htmlAttribute: "style").removeAttribute(htmlAttribute: "class").remove(htmlTag: "font")
                        deets.attributedText = NSMutableAttributedString.bodyMutableAttributedString(rawHtml, font:deets.font )
                    }
                }
                
                if let jpg = self.doc?.jpg {
                    self.setImage(url: jpg)
                    self.albumImage.backgroundColor = UIColor.black

                } else {
                    self.setImage(url: (self.doc!.iconUrl()))
                }
                
                if let files = self.doc?.sortedFiles {
                    self.audioFiles = files
                }
                
            })
        }

    }
    
    /**
     An archive in Realm has to be set up first before you can set up a notification token for it
     */
    func setUpToken() {
        
        guard self.archive != nil else {
            return
        }
        
        if let ar = self.archive {
        
            if notificationToken == nil {
                notificationToken = RealmManager.defaultSortedFiles(identifier: ar.identifier)?.addNotificationBlock({[weak self] (changes ) in
                    switch changes {
                    case .initial(let results):
                        self?.updateRows(playerFiles: results)
                        break
                    case .update(let results, _, _, _):
                        self?.updateRows(playerFiles: results)
                    case .error(let error):
                        print (error)
                        break
                    }
                })
            }
        }
        
    }
    
    /**
     This loops through all files in audioFiles, and if realm has it a check mark is added/updated to the row.  If not, it restores the plus
     */
    func updateRows(playerFiles:Results<IAPlayerFile>) {
        
        var playerHash = [String:IAPlayerFile]()
        for file in playerFiles {
            playerHash[file.name] = file
        }
        var changedIndexPaths = [IndexPath]()
        for (index,file) in self.audioFiles.enumerated() {
            // print("\(file.name) \(index)")
            let fileHash = filesNameInRealm[file.name!]
            if playerHash[file.name!] != nil {
                if fileHash == nil {
                    filesNameInRealm[file.name!] = playerHash[file.name!]
                    changedIndexPaths.append(IndexPath(row:index, section:0))
                }
            } else {
                if fileHash != nil {
                    filesNameInRealm[file.name!] = nil
                    changedIndexPaths.append(IndexPath(row:index, section:0))
                }
            }
        }
        
        // print(changedIndexPaths)
         print(filesNameInRealm)
        
        // If there are any changes, update the table
        if changedIndexPaths.count > 0 {
            self.tableView.reloadRows(at: changedIndexPaths, with: .none)
        }
        
        
    }
    

    func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: -
    /**
     Initial tableview.reloadData() happens here after the main image is fetched
     */
    func setImage(url:URL) {
        self.albumImage.af_setImage(withURL: url,
                               placeholderImage: nil,
                               filter: nil,
                               progress: nil,
                               progressQueue: DispatchQueue.main,
                               imageTransition: .noTransition,
                               runImageTransitionIfCached: true) { response in
                                
                                switch response.result {
                                case .success(let image):
                                    let size = image.size
                                    let height = (self.imageWidth.constant * size.height ) / size.width
                                    self.imageHeight.constant = round(height)
                                    self.originalSize = CGSize(width: self.imageWidth.constant, height: self.imageHeight.constant)
                                    
                                    self.backgroundImage.image = image
                                    break
                                case .failure( _):
                                    break
                                }

                                self.tableView.reloadData()
                                self.layoutTableViewOffset()
                                self.albumImage.backgroundColor = UIColor.white
                                
                                // Now that initial set up of the UI is complete, lets set up a realm notification
                                // token if there already is an archive
                                if let ar = RealmManager.archives(identifier: self.identifier!).first {
                                    self.archive = ar
                                    self.setUpToken()
                                }
        }
    }
    
    /**
     This is necessary to auto layout the tableViewHeaderView as AutoLayout is doesn't work with with
     UITableView.tableViewHeaderView's
     */
    func layoutTableViewOffset() {
        var fr = self.topView.frame
        // print("frame size height: \(self.imageHeight.constant)")
        // print("title size height: \(self.docTitle.bounds.size.height)")
        fr.size.height =
            self.imageHeight.constant +
            10 + self.docDeets.bounds.size.height +
            10 + self.addAllButton.bounds.size.height + 20
        
        self.topView.frame = fr
        self.topView.setNeedsLayout()
        self.tableView.tableHeaderView = self.topView
        self.adjustColorsAndRemoveBlur()

    }
    
    /**
     Remmoves the initial overlay that blocks the ui before
     we've gotten a response from the Archive and laid out the tableview
     */
    func adjustColorsAndRemoveBlur() {
        
        self.docDeets.textColor = UIColor.white
        self.activityIndicatorView.stopAnimation()
        
        UIView.animate(withDuration: 0.33, animations: {
            self.blurView.alpha = 0
        }) { (done) in
            self.blurView.isHidden = true
        }
    }

    var originalSize: CGSize?
    var isExpanded = false
    @IBAction func expandButton(_ sender: Any) {

        if let img = albumImage.image {
            var width = self.view.bounds.size.width
            var height = (width * img.size.height ) / img.size.width
            
            if isExpanded, let size = originalSize {
                height = size.height
                width = size.width
                docDeets.numberOfLines = 3
            } else {
                docDeets.numberOfLines = 0
            }
            
            self.imageWidth.constant = width
            self.imageHeight.constant = height
            
            UIView.animate(withDuration: 0.33, animations: {
                self.topView.layoutIfNeeded()
                self.layoutTableViewOffset()
            }) { (done) in
                self.isExpanded = !self.isExpanded
            }
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearNavigation()
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doesPlayerFileExist(fileName:String)->Bool {
        if let ident = identifier {
            if let hash = RealmManager.hashOfArchiveFiles(identifier: ident) {
                return hash[fileName] != nil
            }
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
        cell.addButton.tag = indexPath.row
        
        // Not double targets just to be safe for reuse
        cell.addButton.removeTarget(self, action: #selector(IADocViewController.didPressPlusButton(_:)), for:.touchUpInside)
        cell.addButton.removeTarget(self, action: #selector(IADocViewController.didPressCheckmark(_:)), for:.touchUpInside)
        
        // There has to be a better way to express this logic
        if filesNameInRealm[file.name!] != nil  {
            cell.addButton.setIAIcon(.checkmark, forState: .normal)
            cell.addButton.addTarget(self, action: #selector(IADocViewController.didPressCheckmark(_:)), for:.touchUpInside)
        } else {
            cell.addButton.setIAIcon(.plus, forState: .normal)
            cell.addButton.addTarget(self, action: #selector(IADocViewController.didPressPlusButton(_:)), for:.touchUpInside)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = audioFiles[indexPath.row]
        if let theDoc = doc {
            IAPlayer.sharedInstance.playFile(file: file, doc: theDoc)
        }

    }

    @IBAction func didPressCheckmark(_ sender: UIButton) {
        
        if self.doc != nil {
            let file = audioFiles[sender.tag]
            if let playerFile = filesNameInRealm[file.name!] {
                RealmManager.deleteFile(file: playerFile!)
            }
        }
    }
    
    @IBAction func didPressPlusButton(_ sender: UIButton) {
        let file = audioFiles[sender.tag]
        if let ar = reInitArchive(archive: self.archive) {
            RealmManager.addFile(archive: ar, file: file)
        }
        // Now that we have a realm Archive, set up notification (if not already set up)
        setUpToken()
    }
    
    @IBAction func didPressAllAdd(_ sender: Any) {
        
        if let ar = self.reInitArchive(archive: self.archive) {
            for file in audioFiles {
                RealmManager.addFile(archive: ar, file: file)
            }
        }
        
        // Now that we have a realm Archive, set up notification (if not already set up)
        setUpToken()
    }
    
    fileprivate func reInitArchive(archive:IAArchive?) -> IAArchive? {
        
        if let ar = archive {
            if ar.isInvalidated {
                notificationToken = nil
                self.archive = RealmManager.addArchive(doc: doc!)
            }
        } else {
            self.archive = RealmManager.addArchive(doc: doc!)
        }
        
        return self.archive
    }
    
    deinit {
        notificationToken?.stop()
    }
    
}
