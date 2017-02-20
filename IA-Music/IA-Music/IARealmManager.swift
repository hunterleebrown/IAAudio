//
//  IARealmManager.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/12/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import Foundation
import RealmSwift

typealias ArchiveDocAndFile = (doc:IAArchiveDocMappable, file:IAFileMappable)


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
    
    func archives(identifier:String) ->Results<IAArchive> {
        let archivePredicate = NSPredicate(format: "identifier = %@", identifier)
        return realm.objects(IAArchive.self).filter(archivePredicate)
    }
    
    func archives()->Results<IAArchive> {
        return (realm?.objects(IAArchive.self).sorted(byKeyPath: "identifierTitle"))!
    }
    
    func deleteFile(docAndFile:ArchiveDocAndFile) {
    
        let predicate = NSPredicate(format: "name = %@ AND archive.identifier = %@", docAndFile.file.name!, docAndFile.doc.identifier!)
        let fileResults = realm.objects(IAPlayerFile.self).filter(predicate)
        
        if fileResults.count > 1 {
            return
        }
        
        try! realm.write {
            realm.delete(fileResults)
        }
    }
    
    
    func addFile(docAndFile:ArchiveDocAndFile) {
        
        //Check for Archive first
        let archivePredicate = NSPredicate(format: "identifier = %@", docAndFile.doc.identifier!)
        let archiveResults = realm.objects(IAArchive.self).filter(archivePredicate)
        var archive : IAArchive?
        if archiveResults.count > 0 {
            archive = archiveResults.first
        }
        
        //var existingFile = realm.objects(IAPlayerFile.self).filter("name = '\(docAndFile.file.name!)' AND archive.identifier = '\(docAndFile.doc.identifier!)'")
        let predicate = NSPredicate(format: "name = %@ AND archive.identifier = %@", docAndFile.file.name!, docAndFile.doc.identifier!)
        let fileResults = realm.objects(IAPlayerFile.self).filter(predicate)
        
        if fileResults.count > 0 {
            return
        }
        
        if archive == nil {
            archive = IAArchive()
            archive?.identifier = docAndFile.doc.identifier!
            archive?.identifierTitle = docAndFile.doc.title!
            if let creator = docAndFile.doc.creator {
                archive?.creator = creator
            }
            try! realm.write {
                realm.add(archive!)
            }
        }
        
        let newFile = IAPlayerFile()
        newFile.archive = archive
        newFile.name = docAndFile.file.name!
        if let title = docAndFile.file.title {
            newFile.title = title
        }
        newFile.urlString = docAndFile.doc.fileUrl(file: docAndFile.file).absoluteString
        if let size = docAndFile.file.size {
            newFile.size = size
        }

        if let length = docAndFile.file.length {
            newFile.length = length
        }
        
        if let track = docAndFile.file.cleanedTrack {
            newFile.displayOrder.value = Int16(track)
        }
        
        try! realm.write {
            realm.add(newFile)
            archive?.files.append(newFile)
        }
        
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
    
    func defaultSortedFiles(identifier:String) -> Results<IAPlayerFile>? {
        
        let archivePredicate = NSPredicate(format: "identifier = %@", identifier)
        let archiveResult = realm.objects(IAArchive.self).filter(archivePredicate).first
        return archiveResult?.files.sorted(byKeyPath: "displayOrder")
    }
    
}
