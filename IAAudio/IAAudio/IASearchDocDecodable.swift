//
//  IAMapperDoc.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/10/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import Foundation

class IAResponse: Decodable {
    var docs: [IASearchDocDecodable] = [IASearchDocDecodable]()

    enum CodingKeys: String, CodingKey {
        case docs
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.docs = try values.decodeIfPresent([IASearchDocDecodable].self, forKey: .docs)!
    }
}


class IASearchResults: Decodable {
    var response: IAResponse?

    enum CodingKeys: String, CodingKey {
        case response
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let resp = try values.decodeIfPresent(IAResponse.self, forKey: .response) {
            self.response = resp
        } 
    }
}


class IASearchDocDecodable: Decodable {
    
    var identifier: String?
    var title: String?
    var desc: String?
    var collection: [String]?
    var subject: Any?
    var creator: Any?
    var contentDate: String?
    var archiveDate: String?


    enum CodingKeys: String, CodingKey {
        case identifier
        case title
        case desc
        case collection
        case subject
        case creator
        case contentDate
        case archiveDate
    }

//    func mapping(map: Map) {
//        identifier <- map["identifier"]
//        title <- map["title"]
//        desc <- map["description"]
//        collection <- map["collection"]
//        subject <- map["subject"]
//        creator <- map["creator"]
//        contentDate <- map["date"]
//        archiveDate <- map["publicdate"]
//    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try values.decodeIfPresent(String.self, forKey: .identifier)
        self.title = try values.decodeIfPresent(String.self, forKey: .title)
        self.desc = try values.decodeIfPresent(String.self, forKey: .desc)

        let throwables = try values.decode([Throwable<String>].self, forKey: .collection)
        self.collection = throwables.compactMap { try? $0.result.get() }

//        self.subject = try values.decodeIfPresent(Any.self, forKey: .subject)
//        self.creator = try values.decodeIfPresent(Any.self, forKey: .creator)

        self.contentDate = try values.decodeIfPresent(String.self, forKey: .contentDate)
        self.archiveDate = try values.decodeIfPresent(String.self, forKey: .archiveDate)
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



