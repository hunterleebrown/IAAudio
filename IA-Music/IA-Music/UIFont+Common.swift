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
        let attributes: [String : Any] = [
            UIFontDescriptorFamilyAttribute : familyName,
            UIFontDescriptorSizeAttribute : pointSize,
            UIFontDescriptorTraitsAttribute : [UIFontSymbolicTrait : UIFontDescriptorSymbolicTraits(traits).rawValue,
                                               UIFontWeightTrait : self.weight]
        ]
        
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    var weight: Double {
        get {
            let fontAttributes = fontDescriptor.object(forKey: UIFontDescriptorTraitsAttribute) as? NSDictionary
            return (fontAttributes?[UIFontWeightTrait] as? Double) ?? Double(UIFontWeightRegular)
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
