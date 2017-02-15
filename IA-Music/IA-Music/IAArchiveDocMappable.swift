//
//  IAMetaDocMappable.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/11/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import Foundation
import ObjectMapper

class IAArchiveDocMappable: Mappable {

    var metadata: [String:Any] = [:]
    var reviews: [[String:String]] = [[:]]
    var files: [IAFileMappable]?

    // MARK: - ObjectMapper
    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        files <- map["files"]
        metadata <- map["metadata"]
    }

    var identifier: String? {
        get {
            return metadata["identifier"] as? String
        }
    }

    var desc: String? {
        get {
            return metadata["description"] as? String
        }
    }

    var subject: String? {
        get {
            return metadata["subject"] as? String
        }
    }
    
    var creator: String? {
        get {
            
            if let cre = metadata["creator"] as? [String] {
                return cre.joined(separator: ", ")
            } else if let cre = metadata["creator"] as? String {
                return cre
            }
            return nil
        }
    }
    
    var uploader: String? {
        get {
            return metadata["uploader"] as? String
        }
    }

    var title: String? {
        get {
            return metadata["title"] as? String
        }
    }
    
    var artist: String? {
        get {
            
            if let cre = metadata["artist"] as? [String] {
                return cre.joined(separator: ", ")
            } else if let cre = metadata["artist"] as? String {
                return cre
            }
            return nil
        }
    }
    
    var sortedFiles: [IAFileMappable]? {
        guard files != nil else { return nil}
        if let fs = files {
            return fs.sorted(by: { (one, two) -> Bool in
                guard one.cleanedTrack != nil else { return false}
                return one.cleanedTrack! < two.cleanedTrack!
            })
        }
    
        return nil
    }
    
    func iconUrl()->URL {
        let itemImageUrl = "http://archive.org/services/img/\(identifier!)"
        return URL(string: itemImageUrl)!
    }
    
    func fileUrl(file:IAFileMappable) ->URL {
    
        let urlString = "http://archive.org/download/\(identifier!)/\(file.name!)"
        return URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!

    }
    
}


class IAFileMappable: Mappable {

    var name : String?
    var title : String?
    var track : String?
    var size : String?
    var format: String?
    var length: String?
    
    required init?(map: Map) {
        
        if map.JSON["format"] as! String != "VBR MP3" {
            return nil
        }
        
    }
    
    func mapping(map: Map) {
        name   <- map["name"]
        format <- map["format"]
        title  <- map["title"]
        size   <- map["size"]
        length <- map["length"]
        track  <- map["track"]
    }
    
    var cleanedTrack: Int?{
        
        if let tr = track {
            if let num = Int(tr) {
                return num
            } else {
                let sp = tr.components(separatedBy: "/")
                if let first = sp.first {
                    let trimmed = first.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    return Int(trimmed) ?? nil
                }
            }
        }
        return nil
    }
    
}
