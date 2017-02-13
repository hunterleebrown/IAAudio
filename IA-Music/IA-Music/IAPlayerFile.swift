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
    dynamic var archive: IAArchive?
    
    func displayTitle() -> String {
        return title.isEmpty ? name : title
    }
    
}


class IAArchive: Object {
    dynamic var identifier = ""
    dynamic var identifierTitle = ""
    let files = List<IAPlayerFile>()
}
