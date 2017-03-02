//
//  IAMapperDoc.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/10/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import Foundation
import ObjectMapper

class IASearchDocMappable: Mappable {
    
    var identifier: String?
    var title: String?
    var desc: String?
    var collection: [String]?
    var subject: Any?
    var creator: Any?
    var contentDate: String?
    var archiveDate: String?

    
    // MARK: - ObjectMapper
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        identifier <- map["identifier"]
        title <- map["title"]
        desc <- map["description"]
        collection <- map["collection"]
        subject <- map["subject"]
        creator <- map["creator"]
        contentDate <- map["date"]
        archiveDate <- map["publicdate"]

        
    }

    
    var displaySubject: String? {
        if let sub = subject as? Array<String> {
            return sub.joined(separator: ", ")
        } else if let sub = subject as? String {
            return sub
        }
        
        return nil
    }
    
    var displayCreator: String? {
        if let sub = creator as? Array<String> {
            return sub.joined(separator: ", ")
        } else if let sub = creator as? String {
            return sub
        }
        
        return nil
    }
    
    var displayArchiveDate: String? {
        if let date = archiveDate {
            return StringUtils.shortDateFromDateString(date)
        }
        return nil
    }
    
    var displayContentDate: String? {
        if let date = contentDate {
            return StringUtils.shortDateFromDateString(date)
        }
        return nil
    }
    
    var iconUrl: URL {
        let itemImageUrl = "http://archive.org/services/img/\(identifier!)"
        return URL(string: itemImageUrl)!
    }
    
}



