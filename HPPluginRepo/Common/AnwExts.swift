//
//  AnwExts.swift
//  HPPluginRepo
//
//  Created by Hu, Peng on 30/11/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import Foundation
import UIKit

public extension Float {
    static func == (lhs: Float, rhs: Float) -> Bool {
        return fabsf(rhs - lhs) < FLT_EPSILON
    }
    static func != (lhs: Float, rhs: Float) -> Bool {
        return fabsf(rhs - lhs) >= FLT_EPSILON
    }
}

public extension CGPoint {
    public func add(_ point: CGPoint) -> CGPoint {
        return CGPoint.init(x: self.x + point.x, y: self.y + point.y)
    }
    
    public func divide(by point: CGPoint) -> CGPoint {
        return CGPoint.init(x: self.x / point.x, y: self.y / point.y)
    }
    
    public func restricted(to bound: CGRect) -> CGPoint {
        var x = self.x
        var y = self.y
        x = max(x, bound.minX)
        x = min(x, bound.maxX)
        y = max(y, bound.minY)
        y = min(y, bound.maxY)
        return CGPoint.init(x: x, y: y)
    }
    
    public func slope(with point: CGPoint) -> Float {
        return Float((self.y - point.y) / (self.x - point.x))
    }
}

public extension CGRect {
    public static func rectOfCircle(center:CGPoint, radius: CGFloat) -> CGRect {
        return CGRect.init(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
    }
    
    public var center: CGPoint {
        return CGPoint.init(x: self.width/2.0 + self.origin.x, y: self.height/2.0 + self.origin.y)
    }
}

public extension UIViewController {
    
    public func quickAdd(childViewController: UIViewController) {
        childViewController.willMove(toParentViewController: self)
        self.view.addSubview(childViewController.view)
        self.addChildViewController(childViewController)
        childViewController.didMove(toParentViewController: self)
    }
    
    public func quickRemove(childViewController: UIViewController) {
        childViewController.willMove(toParentViewController: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParentViewController()
        childViewController.didMove(toParentViewController: nil)
        
    }
    
    public static func loadFromStoryboard(with identifier: String?=nil) -> UIViewController {
        
        let _identifier = identifier == nil ? self.nameOfClass : identifier
        
        return UIStoryboard.default().instantiateViewController(withIdentifier:_identifier!)
    }
}

public extension UIStoryboard {
    
    public static func `default`() -> UIStoryboard {
        let infoKey = UIDevice.isPhone() ? "UIMainStoryboardFile~iphone" : "UIMainStoryboardFile~ipad"
        var value: String? = Bundle.main.object(forInfoDictionaryKey: infoKey) as? String
        value = value ?? "Main"
        return UIStoryboard.init(name: value!, bundle: Bundle.main)
    }
}

public extension UIDevice {
    
    public static func isPhone() -> Bool {
        return UIDevice.current.model == "iPhone"
    }
}

public extension NSObject {
    public class var nameOfClass: String{
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    public var nameOfClass: String {
        return NSStringFromClass(self as! AnyClass).components(separatedBy: ".").last!
    }
}

public extension Float {
    public static var random099: Float {
        return Float(arc4random()%100)/100.0
    }
}

public extension UIColor {
    public static var randomColor: UIColor {
        return UIColor.init(red: CGFloat(Float.random099), green: CGFloat(Float.random099), blue: CGFloat(Float.random099), alpha: 1.0)
    }
    public static func color01(from tuple: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)) -> UIColor {
        return UIColor.init(red: tuple.r, green: tuple.g, blue: tuple.b, alpha: tuple.a)
    }
    public static func color255(from tuple: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)) -> UIColor {
        return UIColor.init(red: tuple.r/255.0, green: tuple.g/255.0, blue: tuple.b/255.0, alpha: tuple.a)
    }
}
