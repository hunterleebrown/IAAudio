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
        
        let audioFiles = files?.filter({ (f) -> Bool in
            f.format == IAFileMappableFormat.mp3
        })
        
        if let fs = audioFiles {
            return fs.sorted(by: { (one, two) -> Bool in
                guard one.cleanedTrack != nil, two.cleanedTrack != nil else { return false}
                return one.cleanedTrack! < two.cleanedTrack!
            })
        }
    
        return nil
    }
    
    func iconUrl()->URL {
        let itemImageUrl = "http://archive.org/services/img/\(identifier!)"
        return URL(string: itemImageUrl)!
    }
    
    func rawDescription()->String? {
        return metadata["description"] as? String ?? nil
    }
    func noHTMLDescription()->String? {
        guard desc != nil else { return nil }
        if let desc = self.rawDescription() {
            return desc.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        }
        return nil
    }
    
    var jpg: URL? {
        
        let jpgs = files?.filter({ (file) -> Bool in
            file.format == .jpg
        })
        
        if let js = jpgs {
            guard js.count > 0  else { return nil}
            if let name = js.first?.name {
                return URL(string:"http://archive.org/download/\(identifier!)/\(name)")
            }
        }
        return nil
    }
    
    func fileUrl(file:IAFileMappable) ->URL {
        let urlString = "http://archive.org/download/\(identifier!)/\(file.name!)"
        return URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
    }
    
}

enum IAFileMappableFormat: String {
    case mp3 = "VBR MP3"
    case jpg   = "JPEG"
    case other
}


class IAFileMappable: Mappable {

    var name : String?
    var title : String?
    var track : String?
    var size : String?
    var format: IAFileMappableFormat?
    var length: String?
    
    
    required init?(map: Map) {
        switch map.JSON["format"] as! String {
        case IAFileMappableFormat.mp3.rawValue:
            format = .mp3
        case IAFileMappableFormat.jpg.rawValue:
            format = .jpg
            if map.JSON["source"] as! String == "origin" {
                break
            }
        default:
            return nil
        }
    }
    
    func mapping(map: Map) {
        name   <- map["name"]
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
    
    var calculatedSize: String? {
    
        if let s = size {
            if let rawSize = Int(s) {
                return StringUtils.sizeString(size: rawSize)
            }
        }
        return nil
    }
    
    
    func displayLength() -> String? {
        if let l = length {
            return StringUtils.timeFormatter(timeString: l)
        }
        return nil
    }
    
    
}
