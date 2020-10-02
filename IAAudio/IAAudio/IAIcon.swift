//
//  IAIcon.swif
//  IA Icons
//

import Foundation
import UIKit


public extension UIBarButtonItem {
    
    /**
     To set an icon, use i.e. `barName.IAIcon = IAIconType.play`
     */
    func setIAIcon(_ icon: IAIconType, iconSize: CGFloat) {
        
        FontLoader.loadFontIfNeeded()
        let font = UIFont(name: IAIconStruct.FontName, size: iconSize)
        
        assert(font != nil, IAIconStruct.ErrorAnnounce)
        setTitleTextAttributes([NSAttributedString.Key.font: font!], for: UIControl.State())
        title = icon.text
    }
    
    
    /**
     To set an icon, use i.e. `barName.setIAIcon(IAIconType.play, iconSize: 35)`
     */
    var IAIcon: IAIconType? {
        set {
            
            FontLoader.loadFontIfNeeded()
            let font = UIFont(name: IAIconStruct.FontName, size: 23)
            assert(font != nil,IAIconStruct.ErrorAnnounce)
            setTitleTextAttributes([NSAttributedString.Key.font: font!], for: UIControl.State())
            title = newValue?.text
        }
        
        get {
            if let title = title {
                if let index =  IAIcons.firstIndex(of: title) {
                    return IAIconType(rawValue: index)
                }
            }
            return nil
        }
    }
    
    
    func setIAIconText(prefixText: String, icon: IAIconType?, postfixText: String, size: CGFloat) {
        
        FontLoader.loadFontIfNeeded()
        let font = UIFont(name: IAIconStruct.FontName, size: size)
        
        assert(font != nil, IAIconStruct.ErrorAnnounce)
        setTitleTextAttributes([NSAttributedString.Key.font: font!], for: UIControl.State())
        
        var text = prefixText
        if let iconText = icon?.text {
            
            text += iconText
        }
        text += postfixText
        title = text
    }
}

public extension UIButton {
    
    /**
     To set an icon, use i.e. `buttonName.setIAIcon(IAIconType.play, forState: .Normal)`
     */
    func setIAIcon(_ icon: IAIconType, forState state: UIControl.State) {
        
        if let titleLabel = titleLabel {
            
            FontLoader.loadFontIfNeeded()
            let font = UIFont(name: IAIconStruct.FontName, size: titleLabel.font.pointSize)
            assert(font != nil, IAIconStruct.ErrorAnnounce)
            titleLabel.font = font!
            setTitle(icon.text, for: state)
        }
    }
    
    
    /**
     To set an icon, use i.e. `buttonName.setIAIcon(IAIconType.play, iconSize: 35, forState: .Normal)`
     */
    func setIAIcon(_ icon: IAIconType, iconSize: CGFloat, forState state: UIControl.State) {
        
        setIAIcon(icon, forState: state)
        if let fontName = titleLabel?.font.fontName {
            
            titleLabel?.font = UIFont(name: fontName, size: iconSize)
        }
    }
    
    
    func setIAIconText(prefixText: String, icon: IAIconType?, postfixText: String, size: CGFloat?, forState state: UIControl.State, iconSize: CGFloat? = nil) {
        
        if let titleLabel = titleLabel {
            
            FontLoader.loadFontIfNeeded()
            let textFont = UIFont(name: IAIconStruct.FontName, size: size ?? titleLabel.font.pointSize)
            assert(textFont != nil, IAIconStruct.ErrorAnnounce)
            titleLabel.font = textFont!
            
            let textAttribute = [NSAttributedString.Key.font : titleLabel.font]
            let myString = NSMutableAttributedString(string: prefixText, attributes: textAttribute )
            
            if let iconText = icon?.text {
                
                let iconFont = UIFont(name: IAIconStruct.FontName, size: iconSize ?? size ?? titleLabel.font.pointSize)!
                let iconAttribute = [NSAttributedString.Key.font : iconFont]
                
                let iconString = NSAttributedString(string: iconText, attributes: iconAttribute)
                myString.append(iconString)
            }
            
            let postfixString = NSAttributedString(string: postfixText)
            myString.append(postfixString)
            
            setAttributedTitle(myString, for: state)
        }
    }
    
    
    func setIAIconTitleColor(_ color: UIColor) {
        
        let attributedString = NSMutableAttributedString(attributedString: titleLabel!.attributedText!)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSMakeRange(0, titleLabel!.text!.count))
    }
}


public extension UILabel {
    
    /**
     To set an icon, use i.e. `labelName.IAIcon = IAIconType.play`
     */
    var IAIcon: IAIconType? {
        
        set {
            
            if let newValue = newValue {
                
                FontLoader.loadFontIfNeeded()
                let fontAwesome = UIFont(name: IAIconStruct.FontName, size: self.font.pointSize)
                assert(font != nil, IAIconStruct.ErrorAnnounce)
                font = fontAwesome!
                text = newValue.text
            }
        }
        
        get {
            if let text = text {
                
                if let index =  IAIcons.firstIndex(of: text) {
                    
                    return IAIconType(rawValue: index)
                }
            }
            return nil
        }
    }
    
    /**
     To set an icon, use i.e. `labelName.setIAIcon(IAIconType.play, iconSize: 35)`
     */
    func setIAIcon(_ icon: IAIconType, iconSize: CGFloat) {
        
        IAIcon = icon
        font = UIFont(name: font.fontName, size: iconSize)
    }
    
    
    func setIAIconText(prefixText: String, icon: IAIconType?, postfixText: String, size: CGFloat?, iconSize: CGFloat? = nil) {
        
        FontLoader.loadFontIfNeeded()
        let textFont = UIFont(name: IAIconStruct.FontName, size: size ?? self.font.pointSize)
        assert(textFont != nil, IAIconStruct.ErrorAnnounce)
        font = textFont!
        
        let textAttribute = [NSAttributedString.Key.font : font]
        let myString = NSMutableAttributedString(string: prefixText, attributes: textAttribute )
        
        
        if let iconText = icon?.text {
            
            let iconFont = UIFont(name: IAIconStruct.FontName, size: iconSize ?? size ?? self.font.pointSize)!
            let iconAttribute = [NSAttributedString.Key.font : iconFont]
            
            
            let iconString = NSAttributedString(string: iconText, attributes: iconAttribute)
            myString.append(iconString)
        }
        
        let postfixString = NSAttributedString(string: postfixText)
        myString.append(postfixString)
        
        self.attributedText = myString
    }
    
}


// Original idea from https://github.com/thii/FontAwesome.swift/blob/master/FontAwesome/FontAwesome.swift
public extension UIImageView {
    
    /**
     Create UIImage from IAIconType
     */
    public func setIAIconWithName(_ icon: IAIconType, textColor: UIColor, backgroundColor: UIColor = UIColor.clear) {
        
        self.image = UIImage(icon: icon, size: frame.size, textColor: textColor, backgroundColor: backgroundColor)
    }
}


public extension UITabBarItem {
    
    public func setIAIcon(_ icon: IAIconType) {
        
        image = UIImage(icon: icon, size: CGSize(width: 30, height: 30))
    }
}


public extension UISegmentedControl {
    
    public func setIAIcon(_ icon: IAIconType, forSegmentAtIndex segment: Int) {
        
        FontLoader.loadFontIfNeeded()
        let font = UIFont(name: IAIconStruct.FontName, size: 23)
        assert(font != nil, IAIconStruct.ErrorAnnounce)
        setTitleTextAttributes([NSAttributedString.Key.font: font!], for: UIControl.State())
        setTitle(icon.text, forSegmentAt: segment)
    }
}


public extension UIImage {
    
    public convenience init(icon: IAIconType, size: CGSize, textColor: UIColor = UIColor.black, backgroundColor: UIColor = UIColor.clear) {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.center
        
        // Taken from FontAwesome.io's Fixed Width Icon CSS
        let fontAspectRatio: CGFloat = 1.28571429
        let fontSize = min(size.width / fontAspectRatio, size.height)
        
        FontLoader.loadFontIfNeeded()
        let font = UIFont(name: IAIconStruct.FontName, size: fontSize)
        assert(font != nil, IAIconStruct.ErrorAnnounce)
        let attributes = [NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.backgroundColor: backgroundColor, NSAttributedString.Key.paragraphStyle: paragraph]
        
        let attributedString = NSAttributedString(string: icon.text!, attributes: attributes)
        UIGraphicsBeginImageContextWithOptions(size, false , 0.0)
        attributedString.draw(in: CGRect(x: 0, y: (size.height - fontSize) / 2, width: size.width, height: fontSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!, scale: (image?.scale)!, orientation: (image?.imageOrientation)!)
    }
}


public extension UISlider {
    
    func setIAIconMaximumValueImage(_ icon: IAIconType, customSize: CGSize? = nil) {
        
        maximumValueImage = UIImage(icon: icon, size: customSize ?? CGSize(width: 25, height: 25))
    }
    
    
    func setIAIconMinimumValueImage(_ icon: IAIconType, customSize: CGSize? = nil) {
        
        minimumValueImage = UIImage(icon: icon, size: customSize ?? CGSize(width: 25, height: 25))
    }
}

private struct IAIconStruct {
    
    static let FontName = "ionicons"
    static let ErrorAnnounce = "****** Tech Today - Ionicons font not found in the bundle or not associated with Info.plist when manual installation was performed. ******"
}

private class FontLoader {
    
    private static var __once: () = {
                let bundle = Bundle(for: FontLoader.self)
                let fontURL = bundle.url(forResource: IAIconStruct.FontName, withExtension: "ttf")!
                let data = try! Data(contentsOf: fontURL)
                let provider = CGDataProvider(data: data as CFData)
                let font = CGFont(provider!)
                var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font!, &error) {
                    let errorDescription: CFString = CFErrorCopyDescription(error!.takeUnretainedValue())
                    let nsError = error!.takeUnretainedValue() as AnyObject as! NSError
                    NSException(name: NSExceptionName.internalInconsistencyException, reason: errorDescription as String, userInfo: [NSUnderlyingErrorKey: nsError]).raise()
                }
            }()
    
    struct Static {
        static var onceToken : Int = 0
    }
    
    static func loadFontIfNeeded() {
        if (UIFont.fontNames(forFamilyName: IAIconStruct.FontName).count == 0) {
            
            _ = FontLoader.__once
        }
    }
}
