//
//  Extensions.swift
//  Coconut Co
//
//  Created by Gourav Joshi on 03/10/17.
//  Copyright © 2017 Gourav Joshi. All rights reserved.
//

import UIKit
import Foundation




extension URL {
    var isHidden: Bool {
        get {
            return (try? resourceValues(forKeys: [.isHiddenKey]))?.isHidden == true
        }
        set {
            var resourceValues = URLResourceValues()
            resourceValues.isHidden = newValue
            do {
                try setResourceValues(resourceValues)
            } catch {
                print("isHidden error:", error)
            }
        }
    }
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

extension UIButton {
    
    func underlineButton(text: String) {
        let titleString = NSMutableAttributedString(string: text)
        titleString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, text.count))
        
        titleString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.blue, range: NSMakeRange(0, text.count))
        titleString.addAttribute(NSAttributedStringKey.underlineColor, value: UIColor.blue, range: NSMakeRange(0, text.count))
        self.setAttributedTitle(titleString, for: .normal)
    }
    
    func addBottomBorderWithColor(color: UIColor, height: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - height, width: self.frame.size.width, height: height)
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UITextView {
    func addBottomBorderWithColor(color: UIColor, height: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - height, width: self.frame.size.width, height: height)
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

extension Character {
    var asciiValue: Int {
        get {
            let s = String(self).unicodeScalars
            return Int(s[s.startIndex].value)
        }
    }
}

extension String {
    var length1: Int {
        return self.count
    }
    /*
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, length1) ..< length1)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    } */
    /*
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length1, r.lowerBound)),
                                            upper: min(length1, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[Range(start ..< end)])
    } */
}

extension UIViewController {

    func executeUIProcess(_ block: @escaping () -> Void) {
        DispatchQueue.main.async(execute: block)
    }

    func showAlertViewWithMessage(_ strMessage: String, vc: UIViewController){
        
        let alert = UIAlertController(title: nil, message: strMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let messageFont = [NSAttributedStringKey.font: UIFont(name: "OpenSans-Regular", size: 16.0)!]
        let messageAttrString = NSMutableAttributedString(string: strMessage, attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        let okButton = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil)
        alert.addAction(okButton)
        vc.present(alert, animated: true, completion: nil)
    }
    
    func showAlertViewWithDuration(_ strMessage: String, vc: UIViewController)  {
        let alert = UIAlertController(title: "", message: strMessage, preferredStyle: UIAlertControllerStyle.alert)
        let messageFont = [NSAttributedStringKey.font: UIFont(name: "OpenSans-Regular", size: 16.0)!]
        let messageAttrString = NSMutableAttributedString(string: strMessage, attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        vc.present(alert, animated: true, completion: nil)
        let delay = 2.5 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            alert.dismiss(animated: true, completion: nil)
        })
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func imageQuality(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
    
    func image(with color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context!.setBlendMode(.normal)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context?.clip(to: rect, mask: cgImage!)
        color1.setFill()
        context?.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
            let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            color.setFill()
            UIRectFill(rect)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return image
        }
}


extension UIView {
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.layer.add(animation, forKey: nil)
    }
    
}

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}
extension Date {
    
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear, .weekOfMonth], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}

extension UIColor {
    convenience init(hex:Int, alpha:CGFloat = 1.0) {
        self.init(
            red:   CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8)  / 255.0,
            blue:  CGFloat((hex & 0x0000FF) >> 0)  / 255.0,
            alpha: alpha
        )
    }
}
