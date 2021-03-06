//
//  AnwExts.swift
//  HPPluginRepo
//
//  Created by Hu, Peng on 30/11/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import Foundation
import UIKit

extension Float {
     static func == (lhs: Float, rhs: Float) -> Bool {
        return fabsf(rhs - lhs) < Float.ulpOfOne
    }
     static func != (lhs: Float, rhs: Float) -> Bool {
        return fabsf(rhs - lhs) >= Float.ulpOfOne
    }
}

//extension Date {
//    func beginDateOfThisWeek() -> Date {
//        let calendar = Calendar(identifier:.gregorian)
//        let d = calendar.component(.weekday, from: self)
//        return self
////        return self.addingTimeInterval(<#T##timeInterval: TimeInterval##TimeInterval#>)
//    }
//    func endDateOfThisWeek() -> Date {
//        return self
//    }
//}

 extension CGPoint {
     func add(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + point.x, y: self.y + point.y)
    }
    
     func divide(by point: CGPoint) -> CGPoint {
        return CGPoint(x: self.x / point.x, y: self.y / point.y)
    }
    
     func restricted(to bound: CGRect) -> CGPoint {
        var x = self.x
        var y = self.y
        x = max(x, bound.minX)
        x = min(x, bound.maxX)
        y = max(y, bound.minY)
        y = min(y, bound.maxY)
        return CGPoint(x: x, y: y)
    }
    
     func slope(with point: CGPoint) -> Float {
        return Float((self.y - point.y) / (self.x - point.x))
    }
}

 extension CGRect {
     static func rectOfCircle(center:CGPoint, radius: CGFloat) -> CGRect {
        return CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
    }
    
     var center: CGPoint {
        return CGPoint(x: self.width/2.0 + self.origin.x, y: self.height/2.0 + self.origin.y)
    }
    
     static func rect(with center: CGPoint, size: CGSize) -> CGRect {
        let origin = CGPoint(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5)
        return CGRect(origin: origin, size: size)
    }
}

 extension UIViewController {
    
     func quickAdd(childViewController: UIViewController) {
        childViewController.willMove(toParentViewController: self)
        self.view.addSubview(childViewController.view)
        self.addChildViewController(childViewController)
        childViewController.didMove(toParentViewController: self)
    }
    
     func quickRemove(childViewController: UIViewController) {
        childViewController.willMove(toParentViewController: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParentViewController()
        childViewController.didMove(toParentViewController: nil)
        
    }
    
     static func loadFromStoryboard(_ storyboardName: String? = nil ,with identifier: String?=nil) -> UIViewController {
        
        let _identifier = identifier == nil ? self.nameOfClass : identifier
        var sb = UIStoryboard.default()
        if storyboardName != nil {
            sb = UIStoryboard.init(name: storyboardName!, bundle: nil)
        }
        
        return sb.instantiateViewController(withIdentifier:_identifier!)
    }
}

 extension UIStoryboard {
    
     static func `default`() -> UIStoryboard {
        let infoKey = UIDevice.isPhone() ? "UIMainStoryboardFile~iphone" : "UIMainStoryboardFile~ipad"
        var value: String? = Bundle.main.object(forInfoDictionaryKey: infoKey) as? String
        value = value ?? "Main"
        return UIStoryboard(name: value!, bundle: Bundle.main)
    }
}

 extension UIDevice {
     static func isPhone() -> Bool {
        return UIDevice.current.model == "iPhone"
    }
}

 extension NSObject {
     class var nameOfClass: String{
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
     var nameOfClass: String {
        return NSStringFromClass(self as! AnyClass).components(separatedBy: ".").last!
    }
}

 extension Float {
     static var random099: Float {
        return Float(arc4random()%100)/100.0
    }
}

 extension UIColor {
     static var randomColor: UIColor {
        return UIColor(red: CGFloat(Float.random099), green: CGFloat(Float.random099), blue: CGFloat(Float.random099), alpha: 1.0)
    }
     static func color01(from tuple: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)) -> UIColor {
        return UIColor(red: tuple.r, green: tuple.g, blue: tuple.b, alpha: tuple.a)
    }
     static func color255(from tuple: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)) -> UIColor {
        return UIColor(red: tuple.r/255.0, green: tuple.g/255.0, blue: tuple.b/255.0, alpha: tuple.a)
    }
    
     static func colorFrom(hex: String, with alpha: CGFloat = 1.0) -> UIColor {
        
        /*
         * legnth of hex string should be 6 or 8
         */
        guard hex.count == 6 || hex.count == 8 else {
            return UIColor.gray
        }
        
        var cString: String = hex.uppercased()
        
        if cString.hasPrefix("0X") {
            let index = cString.index(cString.startIndex, offsetBy: 2)
            cString = String(cString[index...])
        }
        
        guard cString.count == 6 else {
            return UIColor.gray
        }
        var fromIndex = hex.index(hex.startIndex, offsetBy: 0)
        var toIndex = hex.index(hex.startIndex, offsetBy: 2)
        let rStr = String(cString[fromIndex..<toIndex])
        
        fromIndex = toIndex
        toIndex = hex.index(fromIndex, offsetBy: 2)
        let gStr = String(cString[fromIndex..<toIndex])
        
        fromIndex = toIndex
        toIndex = hex.index(fromIndex, offsetBy: 2)
        let bStr = String(cString[fromIndex..<toIndex])
        
        var r: UInt32 = 0, g: UInt32 = 0, b: UInt32 = 0
    
        Scanner(string: rStr).scanHexInt32(&r)
        Scanner(string: gStr).scanHexInt32(&g)
        Scanner(string: bStr).scanHexInt32(&b)
        
        return UIColor.color255(from: (r: CGFloat(r), g: CGFloat(g), b: CGFloat(b), a: alpha))
    }
    
}
