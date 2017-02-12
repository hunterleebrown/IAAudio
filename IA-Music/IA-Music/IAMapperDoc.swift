//
//  IAMapperDoc.swift
//  IA-Music
//
//  Created by Hunter Lee Brown on 2/10/17.
//  Copyright © 2017 Hunter Lee Brown. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class IAMapperDoc: Object, Mappable {
    
    var identifier = ""
    var title = ""
    var desc = ""

    
    // MARK: - ObjectMapper
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        identifier <- map["identifier"]
        title <- map["title"]
        desc <- map["description"]

    }

}

class Collection: Object, Mappable {
    
    var identifier = ""
    
    
    // MARK: - ObjectMapper
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        identifier <- map
    }
    
}

