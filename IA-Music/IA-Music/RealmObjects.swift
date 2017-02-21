//
//  IAPlayerFile.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/12/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import Foundation
import RealmSwift

class IAPlayerFile: Object {
    let displayOrder = RealmOptional<Int16>()
    dynamic var downloaded = false
    dynamic var name  = ""
    dynamic var title = ""
    dynamic var urlString = ""
    dynamic var size = ""
    dynamic var length = ""
    dynamic var archiveIdentifier = ""
    
    override static func primaryKey() -> String? {
        return "urlString"
    }
    
    func displayTitle() -> String {
        return title.isEmpty ? name : title
    }
    
    
    func displaySize() -> String? {
        if let rawSize = Int(size) {
            return StringUtils.sizeString(size: rawSize)
        }
        return nil
    }
    
    func displayLength() -> String? {
        if let rawLength = Float(length) {
            return StringUtils.timeFormatted(Int(rawLength))
        } else {
            return length
        }
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
    let files = List<IAPlayerFile>()
    
    override static func primaryKey() -> String? {
        return "title"
    }
}
