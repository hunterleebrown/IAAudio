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
 
    static let sharedInstance: IARealmManger = {
        return IARealmManger()
    }()
    
    init() {
        do {
            realm = try Realm()
            debugPrint("Path to realm file: " + realm.configuration.fileURL!.absoluteString)
        } catch {
            print("Realm init error: \(error)")
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
    
    func addFile(archive:IAArchive, file:IAFileMappable) {
        let predicate = NSPredicate(format: "name = %@ AND archiveIdentifier = %@", file.name!, archive.identifier)
        let fileResults = realm.objects(IAPlayerFile.self).filter(predicate)
        
        if fileResults.count > 0 {
            return
        }
        
        let playerFile = createPlayerFile(identifier: archive.identifier, file: file)
        
        try! realm.write {
            realm.add(playerFile)
            archive.files.append(playerFile)
        }
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
        newFile.archiveIdentifier = identifier
        newFile.name = file.name!
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
    
    
    
    
    
    // MARK: - Downloading
    
    
    
    static func downloadFilePath(_ response: HTTPURLResponse) ->String{
        let fileName = response.suggestedFilename!
        return IAMediaUtils.removeSpecialCharsFromString(fileName)
    }
    
    func downloadFile(playerFile:IAPlayerFile) {
        
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
