//
//  ArchiveSearchDoc.swift
//  IA Music
//
//  Created by Hunter on 10/27/15.
//  Copyright © 2015 Hunter Lee Brown. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}




enum IAMediaType {
    case none
    case audio
    case video
    case text
    case image
    case collection
    case any
    case software
    case etree
    
    var description : String {
        return IAMediaUtils.stringFrom(self)
    }
    
}

class IASearchDoc : NSObject {
    var title : String!
    var itemImageUrl : String!
    var details : String!
    var identifier : String!
    var publicDate : String!
    var date : String!
    var uploader : String!
    var creator : String?
    var type : IAMediaType!
    var _rawFiles : Array<NSDictionary>!
    
    var server : String!
    var directory : String!
    var isDark = false
    

    var _rawDoc : NSDictionary!
    
    var rawDoc : NSDictionary {
        set {
            let dict : NSDictionary = newValue
            
            _rawDoc = newValue
            
            identifier = dict.value(forKey: "identifier") as! String

            if let value = dict.value(forKey: "title")
            {
                title = safeStringFromValue(value as AnyObject)
            }
            
            if let value = dict.value(forKey: "is_dark")
            {
                isDark = value as! Bool
            }
            
            if let value = dict.value(forKey: "description")
            {
                details = safeStringFromValue(value as AnyObject)
            }
            
            if let value = dict.value(forKey: "date")
            {
                date = safeStringFromValue(value as AnyObject)
            }
            
            if let value = dict.value(forKey: "publicDate")
            {
                publicDate = safeStringFromValue(value as AnyObject)
            }
            
            type = IAMediaUtils.mediaTypeFrom((dict.value(forKey: "mediatype") as? String)!)
            
            if let value = dict.value(forKey: "uploader")
            {
                uploader = safeStringFromValue(value as AnyObject)
            }

            if let value = dict["creator"]
            {
                if let cre = value as? String {
                    creator = cre
                }
            }
            
            if dict.value(forKey: "headerImage") == nil
            {
                itemImageUrl = "http://archive.org/services/img/\(identifier!)"
            } else {
                itemImageUrl = dict.value(forKey: "headerImge") as! String
            }
        }
        get {
            return _rawDoc
        }
        
    }
    
    
    override var description : String {
        return  ["creator" : creator, "title" : title, "identifier" : identifier, "mediatype" : type.description, "uploader" : uploader, "image" : itemImageUrl].description
        
    }
    
    
    func safeStringFromValue(_ value:AnyObject)->String
    {
        if value as? NSArray != nil && value.count > 0
        {
            return value.firstObject as! String
        }
        else if (value as? String != nil)
        {
            return value as! String
        }
        return ""
    }
    

    
    
}

class IADetailDoc: IASearchDoc {
    var files : Array<IAFile>! {
        if _rawFiles != nil
        {
            var formattedFiles = [IAFile]()
            for fileDict in _rawFiles
            {
                let f = IAFile(
                    identifier: identifier,
                    title: title,
                    server: server,
                    directory: directory,
                    file: fileDict
                )
                f.identifierTitle = self.title
                formattedFiles.append(f)
            }
            return formattedFiles
        }
        return nil
    }

    func vbrFiles() ->[IAFile]
    {
        var returnFiles = [IAFile]()
        for file in files
        {
            if file.format == IAFileFormat.vbrmp3
            {
                returnFiles.append(file)
            }
        }
        let sFiles = returnFiles.sorted(by: {$0.track < $1.track})
        return sFiles
    }
    
    override var description : String {
        return  ["creator" : creator ?? "",
                 "title" : title,
                 "identifier" : identifier,
                 "mediatype" : type.description,
                 "uploader" : uploader,
                 "image" : itemImageUrl,
                 "files" : vbrFiles()].description
        
    }
    
}
