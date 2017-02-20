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
    
    var filesHash: [String:IAPlayerFile]?
    var notificationToken: NotificationToken? = nil

    var forcedShowNavigationBar = false
    
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
        
        

        
        
        //MARK:
        
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
                        let stripped = rawHtml.removeAttribute(htmlAttribute: "style").removeAttribute(htmlAttribute: "class").remove(htmlTag: "font")
                        
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
        notificationToken = IARealmManger.sharedInstance.realm.addNotificationBlock { [weak self] notification, realm in
            self?.tableView.reloadData()
         
        }
        

    }

    func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
                                case .failure(let _):
                                    break
                                }
                                
                                self.layoutTableViewOffset()
                                self.adjustColorsAndRemoveBlur()
                                
                                self.albumImage.backgroundColor = UIColor.white
                                self.tableView.reloadData()

        }
    }
    
    func layoutTableViewOffset() {
        var fr = self.topView.frame
//        print("frame size height: \(self.imageHeight.constant)")
//        print("title size height: \(self.docTitle.bounds.size.height)")
        fr.size.height =
            self.imageHeight.constant +
            self.docDeets.bounds.size.height +
            self.addAllButton.bounds.size.height + 50
        
        self.topView.frame = fr
        self.tableView.tableHeaderView = self.topView
    }
    

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
            if let hash = IARealmManger.sharedInstance.hashOfArchiveFiles(identifier: ident) {
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
        
        
        cell.addButton.removeTarget(self, action: #selector(IADocViewController.didPressPlusButton(_:)), for:.touchUpInside)
        cell.addButton.removeTarget(self, action: #selector(IADocViewController.didPressCheckmark(_:)), for:.touchUpInside)
        
         if doesPlayerFileExist(fileName: file.name!) {
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
        
        if let doc = self.doc {
            let file = audioFiles[sender.tag]
            IARealmManger.sharedInstance.deleteFile(docAndFile: (doc:doc, file:file))
        }
    }
    
    @IBAction func didPressPlusButton(_ sender: UIButton) {
        if let doc = self.doc {
            let file = audioFiles[sender.tag]
            IARealmManger.sharedInstance.addFile(docAndFile: (doc:doc, file:file))
        }
    }
    
    @IBAction func didPressAllAdd(_ sender: Any) {
        for file in audioFiles {
            IARealmManger.sharedInstance.addFile(docAndFile: (doc:doc!, file:file))
        }
    }
    
    
    deinit {
        notificationToken?.stop()
    }
    
}
