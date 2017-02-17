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
    @IBOutlet weak var topViewTopContraint: NSLayoutConstraint!
    
    @IBOutlet weak var docTitle: UILabel!
    @IBOutlet weak var docDeets: UILabel!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var imageExpand: UIButton!
    
    
    var audioFiles = [IAFileMappable]()
    let service = IAService()
    
    var identifier: String?
    var doc: IAArchiveDocMappable?
    
    var filesHash: [String:IAPlayerFile]?
    var notificationToken: NotificationToken? = nil

    var forcedShowNavigationBar = false
    
    var colors: UIImageColors?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 44
        self.tableView?.tableFooterView = UIView(frame: CGRect.zero)
        self.activityIndicatorView.color = IAColors.fairyRed
        self.activityIndicatorView.startAnimation()
        
        
        if let ident = identifier {
            
            service.archiveDoc(identifier: ident, completion: { (inDoc, error) in
                self.doc = inDoc
                if let title = self.doc?.title {
                    self.docTitle.text = title
                    self.title = title
                }
                
                if let deets = self.docDeets {
                    deets.text = self.doc?.noHTMLDescription()
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
                
                self.tableView.reloadData()
            })
        }
        notificationToken = IARealmManger.sharedInstance.realm.addNotificationBlock { [weak self] notification, realm in
            self?.tableView.reloadData()
        }
        

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
                                    self.colors = image.getColors()
                                    self.originalSize = CGSize(width: self.imageWidth.constant, height: self.imageHeight.constant)
                                    break
                                case .failure(let _):
                                    break
                                }
                                
                                self.layoutTableViewOffset()
                                self.adjustColorsAndRemoveBlur()
                                self.albumImage.backgroundColor = UIColor.white
                                
        }
    }
    
    func layoutTableViewOffset() {
        var fr = self.topView.frame
        print("frame size height: \(self.imageHeight.constant)")
        print("title size height: \(self.docTitle.bounds.size.height)")
        fr.size.height = self.imageHeight.constant + self.docTitle.bounds.size.height + self.docDeets.bounds.size.height + 40
        self.topView.frame = fr
        self.tableView.tableHeaderView = self.topView
    }
    
    func adjustColorsAndRemoveBlur() {
    
        if let colored = self.colors {
            self.topView.backgroundColor = colored.backgroundColor
            self.docTitle.textColor = colored.primaryColor
            self.docDeets.textColor = colored.detailColor
            self.imageExpand.setTitleColor(colored.backgroundColor, for: .normal)
            self.imageExpand.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            self.imageExpand.setIAIcon(.arrowExpand, forState: .normal)

        }
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
        super.viewWillAppear(animated)
        if let navController = navigationController, navController.navigationBar.isHidden {
            navController.setNavigationBarHidden(false, animated: false)
            self.forcedShowNavigationBar = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if forcedShowNavigationBar, let navController = navigationController {
            navController.setNavigationBarHidden(true, animated: false)
        }
        
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
        cell.addButton.isHidden = doesPlayerFileExist(fileName: file.name!)
        cell.addButton.tag = indexPath.row
        cell.addButton.addTarget(self, action: #selector(IADocViewController.didPressPlusButton(_:)), for:.touchUpInside)
        
//        if let colored = colors {
//            cell.titleLabel.textColor = colored.primaryColor
//            cell.contentView.backgroundColor = colored.backgroundColor
//            cell.addButton.setTitleColor(colored.primaryColor, for: .normal)
//        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = audioFiles[indexPath.row]
        if let theDoc = doc {
            IAPlayer.sharedInstance.playFile(file: file, doc: theDoc)
        }

    }
    
    @IBAction func didPressPlusButton(_ sender: UIButton) {
        if let doc = self.doc {
            let file = audioFiles[sender.tag]
            IARealmManger.sharedInstance.addFile(docAndFile: (doc:doc, file:file))
        }
    }
    
    

    
    
    deinit {
        notificationToken?.stop()
    }
    
}
