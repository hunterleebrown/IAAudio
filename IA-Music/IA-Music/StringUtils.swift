//
//  StringUtils.swift
//  IA Music
//
//  Created by Hunter on 11/29/15.
//  Copyright © 2015 Hunter Lee Brown. All rights reserved.
//

import Foundation
import UIKit


struct StringUtils {

    //                       date: "2014-10-15T00:00:00Z",
    static let ArchiveDateFormat = "yyyy'-'MM'-'dd'T'HH:mm:ss'Z'"
    static let ShortDateFormat = "M/d/YYYY"
    
    static func shortDateFromDateString(_ dateString: String) ->String
    {
        let df = StringUtils.formatter
        df.dateFormat = StringUtils.ArchiveDateFormat
        if let sDate = df.date(from: dateString) {
            
            let showDateFormat = StringUtils.formatter
            //            showDateFormat.dateFormat = StringUtils.ShortDateFormat
            showDateFormat.dateStyle = DateFormatter.Style.medium
            return showDateFormat.string(from: sDate)
        } else {
            return ""
        }
        
    }
    
    
    static func timeFormatted(_ totalSeconds:Int) ->String {
        
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours : Int = totalSeconds / 3600
        
        let secs = String(format: "%02d", arguments: [seconds])
        let mins = String(format: "%02d", arguments: [minutes])
        let hs = String(format: "%02d", arguments: [hours])
        
        return "\(hs):\(mins):\(secs)"
    
    }
    
    
    fileprivate static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        return formatter
    }()
    
    
    

}

extension NSMutableAttributedString {
    class func mutableAttributedTextWithFontFromHTML(_ textWithFont:String, font:UIFont)->NSMutableAttributedString {
        
        do {
            let attString =  try NSAttributedString(data: textWithFont.utf8Data!, options:[NSFontAttributeName: font, NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
            
            return NSMutableAttributedString(attributedString: attString)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return NSMutableAttributedString(string: "")
    }
}



extension Data {
    var attributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options:[NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}
extension String {
    var utf8Data: Data? {
        return data(using: .utf8)
    }
}

