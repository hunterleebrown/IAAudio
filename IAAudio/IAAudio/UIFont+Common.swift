//
//  UIFont+Common.swift
//  TechToday
//
//  Created by Chape, Ashleigh on 7/19/16.
//  Copyright © 2016 CBS Interactive. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    func withTraits(traits:UIFontDescriptorSymbolicTraits...) -> UIFont? {
        let attributes: [UIFontDescriptor.AttributeName : Any] = [
            UIFontDescriptor.AttributeName.family : familyName,
            UIFontDescriptor.AttributeName.size : pointSize,
            UIFontDescriptor.AttributeName.traits : [UIFontDescriptor.AttributeName.symbolic : UIFontDescriptorSymbolicTraits(traits).rawValue,
                                                              UIFontDescriptor.TraitKey.weight : self.weight]
        ]
        
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    var weight: Double {
        get {
            let fontAttributes = fontDescriptor.object(forKey: UIFontDescriptor.AttributeName.traits) as? NSDictionary
            return (fontAttributes?[UIFontDescriptor.TraitKey.weight] as? Double) ?? Double(UIFont.Weight.regular.rawValue)
        }
    }
    
    var italic: UIFont? {
        get {
            return withTraits(traits: .traitItalic)
        }
    }
    
    var bold: UIFont? {
        get {
            return withTraits(traits: .traitBold)
        }
    }
}
