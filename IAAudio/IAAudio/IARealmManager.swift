//
//  IARealmManager.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/12/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire


typealias ArchiveDocAndFile = (doc:IAArchiveDocMappable, file:IAFileMappable)

let RealmManager = IARealmManger.sharedInstance

class IARealmManger {
    
    var realm: Realm!
    var NOWPLAYING = "_NOWPLAYING"
 
    static let sharedInstance: IARealmManger = {
        return IARealmManger()
    }()
    
    init() {
        do {
            realm = try Realm()
            debugPrint("Path to realm file: " + realm.configuration.fileURL!.absoluteString)
            self.createNowPlayingList()
        } catch {
            print("Realm init error: \(error)")
        }
    }
    
    func createNowPlayingList() {
        var nowPlayingList = realm.objects(IAList.self).filter("title = '\(NOWPLAYING)'").first
        if nowPlayingList == nil {
            self.syncPlaylist(files: [], title: "_NOWPLAYING", list: nil)
        }
    }
    
    
    
    //MARK: - Doc Use
    
    // This is the use case of search results with just the archive identifier, and you want to remove a file 
    // from an already stashed archive
    func deleteFile(docAndFile:ArchiveDocAndFile) {
    
        let predicate = NSPredicate(format: "name = %@ AND archiveIdentifier = %@", docAndFile.file.name!, docAndFile.doc.identifier!)
        let fileResults = realm.objects(IAPlayerFile.self).filter(predicate)
        
        if fileResults.count > 1 {
            return
        }
        
        if let file = fileResults.first {
            deleteFile(file: file)
        }
    }
    
    
    func addArchive(doc:IAArchiveDocMappable)->IAArchive? {
    
        //Check for Archive first
        let archivePredicate = NSPredicate(format: "identifier = %@", doc.identifier!)
        let archiveResults = realm.objects(IAArchive.self).filter(archivePredicate)
        var archive : IAArchive?
        if archiveResults.count > 0 {
            archive = archiveResults.first
        }
        
        if archive == nil {
            archive = IAArchive()
            archive?.identifier = doc.identifier!
            archive?.title = doc.title!
            if let creator = doc.creator {
                archive?.creator = creator
            }
            try! realm.write {
                realm.add(archive!)
            }
        }
        
        return archive
    }
    
    func addAll(archive:IAArchive, files:[IAFileMappable]) {
        try! realm.write {
            for file in files {
                self.addRealmFile(archive: archive, file: file)
            }
        }
    }
    
    func addFile(archive:IAArchive, file:IAFileMappable) {
        try! realm.write {
            self.addRealmFile(archive: archive, file: file)
        }
    }
    
    func addRealmFile(archive:IAArchive, file: IAFileMappable) {
    
        let predicate = NSPredicate(format: "name = %@ AND archiveIdentifier = %@", file.name!, archive.identifier)
        let fileResults = realm.objects(IAPlayerFile.self).filter(predicate)
        
        if fileResults.count > 0 {
            return
        }
        
        let playerFile = createPlayerFile(identifier: archive.identifier, file: file)
    
        realm.add(playerFile)
        archive.files.append(playerFile)
    }
    
    
    
    // This is the use case of search results with just the archive identifier, and you want to add a file
    // to an already stashed archive, or create a new archive
    func addFile(docAndFile:ArchiveDocAndFile) {
        
        //Check for Archive first
        let archivePredicate = NSPredicate(format: "identifier = %@", docAndFile.doc.identifier!)
        let archiveResults = realm.objects(IAArchive.self).filter(archivePredicate)
        var archive : IAArchive?
        if archiveResults.count > 0 {
            archive = archiveResults.first
        }
        
        let predicate = NSPredicate(format: "name = %@ AND archiveIdentifier = %@", docAndFile.file.name!, docAndFile.doc.identifier!)
        let fileResults = realm.objects(IAPlayerFile.self).filter(predicate)
        
        if fileResults.count > 0 {
            return
        }
        
        if archive == nil {
            archive = IAArchive()
            archive?.identifier = docAndFile.doc.identifier!
            archive?.title = docAndFile.doc.title!
            if let creator = docAndFile.doc.creator {
                archive?.creator = creator
            }
            try! realm.write {
                realm.add(archive!)
            }
        }
        
        let newFile = self.createPlayerFile(identifier: (archive?.identifier)!, file:docAndFile.file)
        
        try! realm.write {
            realm.add(newFile)
            archive?.files.append(newFile)
        }
        
    }
    
    private func createPlayerFile(identifier:String, file:IAFileMappable)->IAPlayerFile {
        let newFile = IAPlayerFile()
        
        newFile.setCompoundName(name: file.name!)
        newFile.setCompoundArchiveIdentifier(identifier: identifier)
        
        let archive = self.archives(identifier: identifier).first
        newFile.archiveTitle = (archive?.title)!
        
        if let title = file.title {
            newFile.title = title
        }
        
        let urlString = "http://archive.org/download/\(identifier)/\(file.name!)"
        
        newFile.urlString = urlString
        if let size = file.size {
            newFile.size = size
        }
        
        if let length = file.length {
            newFile.length = length
        }
        
        if let track = file.cleanedTrack {
            newFile.displayOrder.value = Int16(track)
        }
        return newFile
    }
    
    //MARK: - Stash Use
    
    /**
     * This will delete all files of the archive and then the archive
     */
    func deleteAllFiles(archive:IAArchive) {
        
        deleteArchiveFolderOffDisk(archiveIdentifier: archive.identifier)
        
        try! realm.write {
            realm.delete(archive.files)
            realm.delete(archive)
        }
    }
    
    /**
     * This will delete the file, and the archive if the archive has no more files in it
     */
    func deleteFile(file:IAPlayerFile) {
        
        deleteFileOffDisk(file: file)
        
        let identifier = file.archiveIdentifier
        try! realm.write {
            realm.delete(file)
            if let archive = self.archives(identifier: identifier).first {
                if archive.files.count == 0 {
                    deleteArchiveFolderOffDisk(archiveIdentifier: identifier)
                    realm.delete(archive)
                }
            }
        }
    }
    
    /**
     * Deletes the file on disk if it's downloaded
     */
    func deleteFileOffDisk(file:IAPlayerFile) {
        // Remove the file from the disk
        if file.downloaded {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let trackPath = documentsURL.appendingPathComponent(file.urlString)
            if FileManager.default.fileExists(atPath: trackPath.path) {
                do {
                    try FileManager.default.removeItem(at: trackPath)
                } catch  {
                    print("couldn't delete: \(trackPath)")
                }
            }
        }
    }
    
    func deleteArchiveFolderOffDisk(archiveIdentifier:String) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let archivePath = documentsURL.appendingPathComponent("tracks/\(archiveIdentifier)")
        
        print("-------------> archive disk path: \(archivePath)")
        
        do {
            try FileManager.default.removeItem(at: archivePath)
        } catch  {
            print("------------> couldn't remove: \(archivePath)")
        }
    }
    
    //MARK: -- Playlist Use
    
    func deletePlaylist(list:IAList) {
    
        try! realm.write {
            realm.delete(list.files)
            realm.delete(list)
        }
    }
    
    func deleteNowPlayingFiles() {
        try! realm.write {
            realm.delete(nowPlayingList().files)
        }
    }
    
    func nowPlayingList()->IAList {
        return realm.objects(IAList.self).filter("title = '\(RealmManager.NOWPLAYING)'").first!
    }
    
    func syncPlaylist(files:[IAPlayerFile], title:String? = nil, list:IAList?) {
        
        try! realm.write {
            if let playList = list {
                
                if let tit = title {
                    playList.title = tit
                }
                
                list?.files.removeAll()
                for file in files {
                    list?.files.append(file)
                }
                
                
            } else {
                let playList = IAList()
                
                if let tit = title {
                    playList.title = tit
                }
                
                for file in files {
                    playList.files.append(file)
                }
                realm.add(playList)
            }
        }
    }
    
    
    //MARK: - Device Storage
    func totalDeviceStorage()->(size:String, numberOfFiles:Int) {
        var totalDownloadSize = 0
        var totalFiles = 0
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let archivePath = documentsURL.appendingPathComponent("tracks")
        do {
            let itemDirs = try FileManager.default.contentsOfDirectory(atPath: archivePath.path)
            for dir in itemDirs {
                guard dir != ".DS_Store" else { continue }
                var directory: ObjCBool = ObjCBool(true)
                let directoryPath = archivePath.appendingPathComponent(dir)
                
//                print("---------> dir path: \(directoryPath)")
                
                if FileManager.default.fileExists(atPath: directoryPath.path, isDirectory: &directory) {
                    
                    let files = try FileManager.default.contentsOfDirectory(atPath: directoryPath.path)
                    for file in files {
                        guard file != ".DS_Store" else { continue }
                        let filePath = directoryPath.appendingPathComponent(file)
                        let attributes = try FileManager.default.attributesOfItem(atPath: filePath.path)
                        print("\(file) attributes: \(attributes[FileAttributeKey.size]!)")
                        totalFiles = totalFiles + 1
                        if let fileSize = attributes[FileAttributeKey.size] as? Int {
                            totalDownloadSize = totalDownloadSize + fileSize
                        }
                    }
                }
            }
        } catch {
            print("ERROR IN FILE FETCH -- or no contentsOfDirectoryAtPath  \(error)")
        }
        return ("\(StringUtils.sizeString(size:totalDownloadSize)) MB", totalFiles)
    }
    
    
    func deviceRemainingFreeSpaceInBytes() -> String? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        guard
            let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
            let freeSize = systemAttributes[.systemFreeSize] as? NSNumber
            else {
                // something failed
                return nil
        }
        
        return StringUtils.sizeString(size: freeSize.intValue)
    }
    
    
    
    
    
    //MARK: - Helpers
    
    // Archives from identifier
    func archives(identifier:String) ->Results<IAArchive> {
        let archivePredicate = NSPredicate(format: "identifier = %@", identifier)
        return realm.objects(IAArchive.self).filter(archivePredicate)
    }
    
    // All Archives
    func archives()->Results<IAArchive> {
        return (realm?.objects(IAArchive.self).sorted(byKeyPath: "title"))!
    }
    
    func hashOfArchiveFiles(identifier:String)->[String:IAPlayerFile]?{
        let archivePredicate = NSPredicate(format: "identifier = %@", identifier)
        let archiveResults = realm.objects(IAArchive.self).filter(archivePredicate)
        var archive : IAArchive?
        if archiveResults.count > 0 {
            archive = archiveResults.first
            
            var hash = [String:IAPlayerFile]()
            if let audFiles = archive?.files {
                for file in audFiles {
                    hash[file.name] = file
                }
                
                return hash
            }
        }
        
        return nil
    }
    
    func hashByFileName(files:Results<IAPlayerFile>) -> [String:IAPlayerFile] {
        var result = [String:IAPlayerFile]()
        files.forEach {
            result[$0.name] = $0
        }
        return result
    }
    
    func defaultSortedFiles(identifier:String) -> Results<IAPlayerFile>? {
        let archivePredicate = NSPredicate(format: "identifier = %@", identifier)
        let archiveResult = realm.objects(IAArchive.self).filter(archivePredicate).first
        return archiveResult?.files.sorted(byKeyPath: "displayOrder")
    }
    
    func playlistFilesForLust(list:IAList) -> List<IAPlayerFile>? {
        let predicate = NSPredicate(format: "title = %@", list.title)
        let result = realm.objects(IAList.self).filter(predicate).first
        return result?.files //.sorted(byKeyPath: "displayOrder")
    }
    
    
    
    // MARK: - Downloading
    
    
    
    static func downloadFilePath(_ response: HTTPURLResponse) ->String{
        let fileName = response.suggestedFilename!
        return IAMediaUtils.removeSpecialCharsFromString(fileName)
    }
    
    func downloadFile(playerFile:IAPlayerFile) {
        
        guard IAReachability.isConnectedToNetwork() else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "networkAlert"), object: nil)
            return
        }
        
        let identifier = playerFile.archiveIdentifier
        
            let destination: DownloadRequest.DownloadFileDestination = { _, response in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let trackPath = documentsURL.appendingPathComponent("tracks/\(identifier)/\(IARealmManger.downloadFilePath(response))")
                return (trackPath, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            print("----------->: \(destination)")
            
            if let escapedUrl = playerFile.urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                
                // TODO: add pregress download and prehaps queue the downloads up somehow
                Alamofire.download(escapedUrl, to: destination).response { response in
                    print(response)
                    if response.error == nil, let downloadPath = response.destinationURL?.path {
                        print("------> downloaded file to here: \(downloadPath)")
                        
                        if let lastPath = response.destinationURL?.lastPathComponent {
                            let savedPath = "tracks/\(identifier)/\(lastPath)"
                            self.updateFileWithLocalPath(playerFile: playerFile, localPath: savedPath)
                        }
                    }
                }
            }
        
    }
    
    
    func updateFileWithLocalPath(playerFile:IAPlayerFile, localPath:String) {
    
        try! realm.write {
            playerFile.urlString = localPath
            playerFile.downloaded = true
        }
    }
    
    
    
    
    
    
    
    
    
    
}
