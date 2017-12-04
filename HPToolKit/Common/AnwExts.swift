//
//  AnwExts.swift
//  HPToolKit
//
//  Created by Hu, Peng on 30/11/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import Foundation
import UIKit

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
