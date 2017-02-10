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
    
    dynamic var identifier = ""
    dynamic var title = ""
    dynamic var desc = ""
    
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
