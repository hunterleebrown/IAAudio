//
//  IAPlayerFile.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/12/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import Foundation
import RealmSwift

enum FileSizeType {
    case appropriate, large, unknown
}

class IAPlayerFile: Object {
    let displayOrder = RealmOptional<Int16>()
    dynamic var downloaded = false
    dynamic var name  = ""
    dynamic var title = ""
    dynamic var urlString = ""
    dynamic var size = ""
    dynamic var length = ""
    dynamic var archiveIdentifier = ""
    dynamic var archiveTitle = ""
    dynamic var compoundKey = ""
    
    
    func setCompoundName(name:String) {
        self.name = name
        compoundKey = compoundKeyValue()
    }

    func setCompoundArchiveIdentifier(identifier:String) {
        self.archiveIdentifier = identifier
        compoundKey = compoundKeyValue()
    }
    
    func compoundKeyValue() -> String {
        return "\(archiveIdentifier)-\(name)"
    }
    
    override static func primaryKey() -> String? {
        return "compoundKey"
    }
    
    var displayTitle: String {
        return title.isEmpty ? name : title
    }
    
    var displaySize: String? {
        if let rawSize = Int(size) {
            return StringUtils.sizeString(size: rawSize)
        }
        return nil
    }
    
    var displayLength: String? {
        if !length.isEmpty {
            return StringUtils.timeFormatter(timeString: length)
        }
        return nil
    }
    
    var sizeType: FileSizeType {
    
        if let rawSize = Int(size) {
            let calc = rawSize / 1000000
            if calc > 50 {
                return FileSizeType.large
            }
        } else {
            return FileSizeType.unknown
        }
        
        return FileSizeType.appropriate
    }
    
}


class IAArchive: Object {
    dynamic var identifier = ""
    dynamic var title = ""
    dynamic var creator = ""
    let files = List<IAPlayerFile>()
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}

class IAList: Object {
    dynamic var title = ""
    let files = List<IAListFile>()
}

class IAListFile: Object {
    dynamic var file: IAPlayerFile!
    dynamic var playlistOrder = 0
}
