//
//  IAMetaDocMappable.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/11/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import Foundation


struct Metadata: Codable {
    var identifier: String?
    var description: String?
    var subject: String?
    var creator: String?
    var uploader: String?
    var title: String?
    var artist: String?
}

class IAArchiveDocDecodable: Decodable {

    var metadata: Metadata
//    var reviews: [[String:String]]
    var files: [IAFileMappable]?

    enum CodingKeys: String, CodingKey {
        case metadata
        case reviews
        case files
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        //self.metadata = try values.decode([String: Any].self, forKey: .metadata)
        self.metadata = try values.decode(Metadata.self, forKey: .metadata)

        let throwables = try values.decode([Throwable<IAFileMappable>].self, forKey: .files)
        self.files = throwables.compactMap { try? $0.result.get() }

    }


    var identifier: String? {
        get {
            return metadata.identifier
        }
    }

    var desc: String? {
        get {
            return metadata.description
        }
    }

    var subject: String? {
        get {
            return metadata.subject
        }
    }
    
    var creator: String? {
        get {
            return metadata.creator
        }
    }
    
    var uploader: String? {
        get {
            return metadata.uploader
        }
    }

    var title: String? {
        get {
            return metadata.title
        }
    }
    
    var artist: String? {
        get {
            return metadata.artist
        }
    }
    
    var sortedFiles: [IAFileMappable]? {
        guard let audFiles = files else { return nil}
        
        let audioFiles = audFiles.filter({ (f) -> Bool in
            f.format == IAFileMappableFormat.mp3
        })
        
        return audioFiles.sorted(by: { (one, two) -> Bool in
            guard one.cleanedTrack != nil, two.cleanedTrack != nil else { return false}
            return one.cleanedTrack! < two.cleanedTrack!
        })    
    }
    
    func iconUrl()->URL {
        let itemImageUrl = "http://archive.org/services/img/\(identifier!)"
        return URL(string: itemImageUrl)!
    }
    
    func rawDescription()->String? {
        return metadata.description
    }
    func noHTMLDescription()->String? {
        guard let des = desc else { return nil }
        return des.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    var jpg: URL? {
        
        guard
            let allFiles = files else { return nil }
        
        let jpgs = allFiles.filter({ (file) -> Bool in
            file.format == .jpg
        })
        
        guard
            jpgs.count > 0,
            let firstJpeg = jpgs.first,
            let name = firstJpeg.name
            else { return nil}
        
        return URL(string:"http://archive.org/download/\(identifier!)/\(name)")
    }
    
    func fileUrl(file:IAFileMappable) ->URL {
        let urlString = "http://archive.org/download/\(identifier!)/\(file.name!)"
        return URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
    }
    
}

enum IAFileMappableFormat: String, Decodable {
    case mp3 = "VBR MP3"
    case jpg   = "JPEG"
    case other
}


class IAFileMappable: Decodable {

    var name : String?
    var title : String?
    var track : String?
    var size : String?
    var format: IAFileMappableFormat?
    var length: String?
    

    enum CodingKeys: String, CodingKey {
        case name
        case title
        case track
        case size
        case fromat
        case length
      }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decodeIfPresent(String.self, forKey: .name)
        self.title = try values.decodeIfPresent(String.self, forKey: .title)
        self.track = try values.decodeIfPresent(String.self, forKey: .track)
        self.size = try values.decodeIfPresent(String.self, forKey: .size)
        self.format = try values.decodeIfPresent(IAFileMappableFormat.self, forKey: .fromat)
        self.length = try values.decodeIfPresent(String.self, forKey: .length)

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
    
    
    var displayLength: String? {
        
        if let l = length {
            return StringUtils.timeFormatter(timeString: l)
        }
        return nil
    }
    
    var displayName: String {
        return self.title ?? self.name!
    }
    
    
}
