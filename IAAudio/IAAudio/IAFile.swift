//
//  ArchiveFile.swift
//  IA Music
//
//  Created by Hunter on 10/27/15.
//  Copyright © 2015 Hunter Lee Brown. All rights reserved.
//

import Foundation

enum IAFileFormat {
    case other
    case jpeg
    case gif
    case h264
    case mpeg4
    case mpeg4512kb
    case h264HD
    case djVuTXT
    case txt
    case processedJP2ZIP
    case vbrmp3
    case mp364Kbps
    case mp3128Kbps
    case mp3
    case mp396Kbps
    case png15
    case epub
    case image
    case png
    
//    var description : String {
//        return IAMediaUtils.stringFrom(IAMediaUtils.mediaTypeFrom(self))
//    }
    
}

class IAFile: NSObject {
    
    var _file : NSDictionary?
    var file : NSDictionary {
        set (newFile){
            
            _file = newFile
            
            self.title = (newFile["title"] != nil ? newFile["title"] as! String : newFile["name"] as! String)
            self.name = newFile["name"] as? String
            
            if let value = newFile["track"] as? String
            {
                if value.components(separatedBy: "/").count > 0 {
                    let comps = value.components(separatedBy: "/")
                    if let trackNumber = Int(comps[0]) {
                        track = Int(trackNumber)
                    }
                } else {
                    if let trackNumber = Int(value) {
                        track = Int(trackNumber)
                    }
                }
            }
            
            if newFile["height"] != nil {
                self.height = newFile["height"] as? String
            }
            
            if newFile["width"] != nil {
                self.width = newFile["width"] as? String
            }
            
            if newFile["format"] != nil
            {
                
                self.format = IAMediaUtils.fileFormatFrom(newFile["format"]! as! String)
                
                if(self.format == IAFileFormat.processedJP2ZIP)
                {
                    self.title = "Flip Through Page Images"
                }
                if(self.format == IAFileFormat.djVuTXT)
                {
                    self.title = "Flip Through Text as Pages";
                }
                if(self.format == IAFileFormat.txt)
                {
                    self.title = "Flip Through Text as Pages";
                }
            }
            else
            {
                self.format = IAFileFormat.other
            }
            
            self.urlString = "http://archive.org/download/\(identifier!)/\(name!)"
            self.url = URL(string: self.urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
            

            
            
        }
        get {
            return _file!
        }
    }
    
    var format : IAFileFormat?
    var name : String?
    var title : String?
    var track : Int?
    var identifier : String?
    var server : String?
    var directory : String?
    var height : String?
    var width : String?
    var identifierTitle : String?
    var size : String?
    var urlString : String!
    var url : URL!

    
    init(identifier : String, title: String, server: String, directory: String, file: NSDictionary)
    {
        super.init()

        self.identifier = identifier
        self.title = title
        self.server = server
        self.directory = directory
        self.file = file
        
    }
    

    override var description : String {
//        return ["track" : String(track!), "format" : format.debugDescription, "url" : urlString].description
        return ["format" : format.debugDescription, "url" : urlString].description
    }
    

    
}
