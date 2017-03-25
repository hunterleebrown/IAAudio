//
//  MYStashChoicesViewController.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/19/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import UIKit
import RealmSwift

class IAMyStashChoicesViewController: IAViewController, UITableViewDelegate, UITableViewDataSource {
    
    var realm: Realm?

    @IBOutlet weak var tableView: UITableView!
    
    var notificationToken: NotificationToken? = nil
    var listCount = 0
    var filesCount = 0
    var archivesCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topTitle(text: "My Audio Stash")
        self.clearNavigation()
        
        self.tableView.sectionHeaderHeight = 44
        self.tableView.tableFooterView = UIView()
        
        realm = RealmManager.realm
        
        if let fc = realm?.objects(IAPlayerFile.self) {
            filesCount = fc.count
        }
        if let ac = realm?.objects(IAArchive.self) {
            archivesCount = ac.count
        }
        if let lc = realm?.objects(IAList.self) {
            listCount = lc.count
        }
        
        self.realmCounts()
        
        notificationToken = realm?.addNotificationBlock { [weak self] notification, realm in
            self?.realmCounts()
            self?.tableView.reloadData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
        super.viewDidAppear(animated)
    }
    
    func realmCounts(){
        
        if let fc = realm?.objects(IAPlayerFile.self) {
            filesCount = fc.count
        }
        if let ac = realm?.objects(IAArchive.self) {
            archivesCount = ac.count
        }
        if let lc = realm?.objects(IAList.self) {
            listCount = lc.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 3 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == ChoiceSelctions.Content.rawValue {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "choiceCell") as! IAMyStashChoicesTableViewCell
            switch indexPath.row {
            case 0:
                let choice = StashChoice.Archives
                cell.stashChoice = choice
                cell.subTitle.text = choice.subTitle(count: archivesCount)
            case 1:
                let choice = StashChoice.Files
                cell.stashChoice = choice
                cell.subTitle.text = choice.subTitle(count: filesCount)
            case 2:
                let choice = StashChoice.Lists
                cell.stashChoice = choice
                cell.subTitle.text = choice.subTitle(count: listCount)
            default:
                break
            }
            return cell
        }

        if indexPath.section == ChoiceSelctions.Find.rawValue {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "findCell") as! IAMyChoicesFindTableViewCell
            return cell
        }

        if indexPath.section == ChoiceSelctions.Data.rawValue {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "dataCell") as! IAMyChoicesDataTableViewCell
            let counts = RealmManager.totalDeviceStorage()
            cell.numberOfDownloadedFiles.text = "\(counts.numberOfFiles)"
            cell.diskSpaceUsage.text = counts.size
            return cell
        }
        
        return UITableViewCell()

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case ChoiceSelctions.Data.rawValue:
            return 66
        default:
            return 66
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.tableView.dequeueReusableCell(withIdentifier: "choicesHeader") as! IAMyChoicesSectionHeaderTableViewCell
        headerView.title.text = self.tableView(tableView, titleForHeaderInSection: section)
        return headerView.contentView
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ChoiceSelctions(rawValue: section)?.title
    }
    
    var selectedChoice: StashChoice?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == ChoiceSelctions.Content.rawValue {
            selectedChoice = StashChoice.init(rawValue: indexPath.row)
//            if selectedChoice != StashChoice.Lists {
                self.performSegue(withIdentifier: "stashPush", sender: nil)
//            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "stashPush" {
            if let controller = segue.destination as? IAMyMusicStashViewController, let choice = selectedChoice {
                if choice == StashChoice.Files {
                    controller.mode = .AllFiles
                }
                if choice == .Lists {
                    controller.mode = .AllPlaylists
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}

enum ChoiceSelctions: Int {
    case Content = 0
    case Data = 1
    case Find = 2
    
    var title: String {
        switch self {
        case .Content:
            return "Content"
        case .Data:
            return "Details"
        case .Find:
            return "Find More Audio"
        }
    }
}


enum StashChoice:Int {
    case Archives = 0
    case Files = 1
    case Lists = 2

    
    var title: String {
        switch self {
        case .Lists:
            return "Playlists"
        case .Archives:
            return "Archives"
        case .Files:
            return "Files"
        }
    }
    
    var iconLabelText: String {
        switch self {
        case .Lists:
            return IAFontMapping.COLLECTION
        case .Archives:
            return IAFontMapping.ARCHIVE
        case .Files:
            return IAIconType.document.text!
        }
    }
    
    func subTitle(count:Int) -> String {
        switch self {
        case .Lists:
            return "\(count) list\(count > 1 ? "s" : "")"
        case .Archives:
            return "\(count) archive\(count > 1 ? "s" : "")"
        case .Files:
            return "\(count) audio file\(count > 1 ? "s" : "")"
        }
    }
    
    
}
