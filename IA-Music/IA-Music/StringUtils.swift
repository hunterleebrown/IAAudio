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
    
    static func timeFormatter(timeString:String) -> String {
        
        let timeComponents = timeString.components(separatedBy: ":")
        guard timeComponents.count > 1 && timeComponents.count < 3 else {
            
            if let time = Float(timeString) {
                return StringUtils.timeFormatted(Int(time.rounded()))
            }
            return timeString
        }
        
        let seconds = Int(timeComponents.last!)
        let minutes = Int(timeComponents[0])
        
        let secs = String(format: "%02d", arguments: [seconds!])
        
        if minutes! <= 60 {
            let mins = String(format: "%02d", arguments: [minutes!])
            return "\(mins):\(secs)"
        }
        
        let hours = minutes! / 60
        let minutesRemainder = minutes! % 60
        
        let h = String(format: "%02d", hours)
        let m = String(format: "%02d", minutesRemainder)
        
        return "\(h):\(m):\(secs)"
    }
    
    static func timeFormatted(_ totalSeconds:Int) ->String {
        
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours : Int = totalSeconds / 3600
        
        let secs = String(format: "%02d", arguments: [seconds])
        let mins = String(format: "%02d", arguments: [minutes])
        
        if hours > 0 {
            let hs = String(format: "%02d", arguments: [hours])
            return "\(hs):\(mins):\(secs)"
        } else {
            return "\(mins):\(secs)"
        }
    }
    
    
    fileprivate static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        return formatter
    }()
    
    static var numberFormatter:NumberFormatter {
        return NumberFormatter()
    }
    
    static func sizeString(size:Int)->String {
        let numberFormatter = self.numberFormatter
        numberFormatter.numberStyle = .decimal
        numberFormatter.roundingMode = .up
        let calc = size / 1000000
        return numberFormatter.string(from: NSNumber(value:Int32(calc)))!
    }

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
    
    class func mutableAttributedString(_ text:String, font:UIFont)->NSMutableAttributedString {
        
        do {
            let attString =  try NSAttributedString(data: text.utf8Data!,
                                                    options:[
                                                        NSFontAttributeName: font,
                                                        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
            
            return NSMutableAttributedString(attributedString: attString)
            
        } catch _ as NSError {
            //print(error.localizedDescription)
        }
        
        return NSMutableAttributedString(string: "")
        
    }
    
    class func bodyMutableAttributedString(_ html:String, font:UIFont)->NSMutableAttributedString {
        let italicFontName: String = font.italic?.fontName ?? font.fontName
        let boldFontName: String = font.bold?.fontName ?? font.fontName
        let boldItalicFontName: String = font.bold?.italic?.fontName ?? font.fontName
        let pointSize: String = String(describing: font.pointSize)
        
        var htmlCss: String = "<html><head><style type=\"text/css\">"
        htmlCss += "body {backgroundColor:transparent !important; color:#000000; font-family: '\(font.fontName)'; font-size:\(pointSize)px; line-height:1em;}"
        htmlCss += "p:first-child:first-letter {color:#FF0000;}"
        htmlCss += "em,i {font-family: '\(italicFontName)'}"
        htmlCss += "b,strong {font-family: '\(boldFontName)'}"
        htmlCss += "b em,b i,em b,i b,strong em,strong i,em strong,i strong {font-family: '\(boldItalicFontName)'}"
        htmlCss += "</style></head><body>\(html)</body></html>"
        
        let attString = NSMutableAttributedString.mutableAttributedString(htmlCss, font: font)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 2.25
        paragraph.paragraphSpacing = font.lineHeight * 0.75
        attString.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: NSMakeRange(0, attString.length))
        
//        let hunter = "hi".replacingOccurrences(of: <#T##String#>, with: <#T##String#>, options: <#T##String.CompareOptions#>, range: <#T##Range<String.Index>?#>)
        
        return attString
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
    
    func remove(htmlTag tag:String)->String {
        return self.replacingOccurrences(of:"(?i)<\(tag)\\b[^<]*>|</\(tag)\\b[^<]*>", with: "", options:.regularExpression, range: nil)
    }
    
    func removeAttribute(htmlAttribute attribute:String)->String {
        return self.replacingOccurrences(of:"(?i)\\s*\(attribute)=\\S*[^<']*'|\"*", with: "", options:.regularExpression, range: nil)
    }
}

