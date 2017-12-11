//
//  ADKFloatingButton.swift
//  AnwDebugKitDemo
//
//  Created by Hu, Peng on 23/10/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

public let ADKFloatingButtonShrinkNotifName = Notification.Name.init("ADKFloatingButtonShrinkNotifName")
public let ADKFloatingButtonExpandNotifName = Notification.Name.init("ADKFloatingButtonExpandNotifName")



public class ADKFloatingButton: UIWindow {
    
    class ADKPlaceHolderViewController : UIViewController {
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return UIStatusBarStyle.lightContent
        }
    }
    
    public var isShow = false
    
    static let sharedInstance = ADKFloatingButton(frame: UIScreen.main.bounds)
    static let holdOnDuration: TimeInterval = 10.0
    private var activeTime: NSDate?
    private var panCenter: CGPoint?
    private var isExpand = false
    private let control: UILabel = UILabel.init()
    private let theme = ADKContext.shared.theme
    private let config = ADKContext.shared.config
    
    private let placeHolder = ADKPlaceHolderViewController.init()

    private override init(frame: CGRect) {
    
        super.init(frame: frame)
        let insets = self.safeAreaInsets
        // init floating button
        control.frame = CGRect.init(origin: CGPoint.init(x: insets.left, y: insets.top), size: ADKContext.shared.theme.floatingButtonSize)
        control.backgroundColor = theme.floationButtonColor
        control.text = theme.floatingButtonText
        control.textAlignment = NSTextAlignment.center
        control.textColor = theme.floationButtonTextColor
        control.font = UIFont.boldSystemFont(ofSize: theme.floationButtonFontSize)
        control.layer.cornerRadius = theme.floatingButtonSize.width * 0.5
        control.adjustsFontSizeToFitWidth = true
        control.clipsToBounds = true
        self.addSubview(control)
        
        // add gesture handlers
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tap(_:)))
        control.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(pan(_:)))
        control.addGestureRecognizer(panGesture)
    
        self.rootViewController = placeHolder
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if(self.rootViewController!.isKind(of: UINavigationController.self)) {
            return super.hitTest(point, with: event)
        } else if (control.frame.contains(point)) {
            return control
        } else {
            return nil
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // gesture handlers
    @objc
    func tap(_ sender: UIGestureRecognizer) {
        if isExpand {
            shrink()
        } else {
            expand()
        }
    }
    @objc
    func pan(_ sender: UIPanGestureRecognizer) {
        
        let point = __CGPointApplyAffineTransform(sender.translation(in: self), self.transform)
        let w = self.bounds.width
        let h = self.bounds.height
        let controlHalfW = control.bounds.width * 0.5
        activeTime = NSDate.init()
        
        if sender.state == UIGestureRecognizerState.began {
            panCenter = control.center
        } else if sender.state == UIGestureRecognizerState.changed {
            control.center = panCenter!.add(point).restricted(to: self.bounds.insetBy(dx: controlHalfW, dy: controlHalfW))
        } else {
            let pinLeft = control.center.divide(by: CGPoint.init(x: w, y: h)).x <= 0.5
            let controlY = control.center.y
            UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: UIViewAnimationOptions(rawValue: 0x01), animations: {
                [unowned self] in
                
                if pinLeft {
                    self.control.center = CGPoint.init(x: controlHalfW, y: controlY)
                    self.control.autoresizingMask = UIViewAutoresizing.init(rawValue: UIViewAutoresizing.flexibleRightMargin.rawValue | UIViewAutoresizing.flexibleTopMargin.rawValue | UIViewAutoresizing.flexibleBottomMargin.rawValue )
                    
                } else {
                    self.control.center = CGPoint.init(x: w - controlHalfW, y: controlY)
                    self.control.autoresizingMask = UIViewAutoresizing.init(rawValue: UIViewAutoresizing.flexibleLeftMargin.rawValue | UIViewAutoresizing.flexibleTopMargin.rawValue | UIViewAutoresizing.flexibleBottomMargin.rawValue )
                }
                
            }, completion: { [unowned self](finished) in
                self.perform(#selector(ADKFloatingButton.resignActive), with: nil, afterDelay: ADKFloatingButton.holdOnDuration)
            })
        }
    }
    
    // private methods
    func expand() {
        
        let scaleRatio = min(self.bounds.width/control.bounds.width, self.bounds.height/control.bounds.height)
        
        UIView.animate(withDuration: 0.15, animations: {
            [unowned self] in
            self.control.transform = CGAffineTransform.init(scaleX: scaleRatio, y: scaleRatio)
            self.control.alpha = 0.0;
            
        }) { [unowned self](finished) in
            let sb = self.config.storyboard
            let rootVC = sb.instantiateInitialViewController()
            
            assert(rootVC != nil, "storyboard \(self.config.storyboardName) must have a root viewcontroller")
            assert(rootVC!.isKind(of: UINavigationController.self), "root view controller of storyboard \(self.config.storyboardName) must be a navigation controller")
            
            self.rootViewController = rootVC
            
            self.isExpand = !self.isExpand
            NotificationCenter.default.post(name: ADKFloatingButtonExpandNotifName, object: nil)
        }
    }
    func shrink() {
        self.rootViewController = placeHolder
        UIView.animate(withDuration: 0.15, animations: {
            [unowned self] in
            self.control.transform = CGAffineTransform.identity
            self.control.alpha = 1.0
        }) { [unowned self](finised) in
            self.isExpand = !self.isExpand
            
            NotificationCenter.default.post(name: ADKFloatingButtonShrinkNotifName, object: nil)
        }
    }
    
    func shift() {
        isShow = !isShow
        if isShow {
            self.makeKeyAndVisible()
            self.perform(#selector(ADKFloatingButton.resignActive), with: nil, afterDelay: ADKFloatingButton.holdOnDuration)
        } else {
            UIApplication.shared.delegate?.window??.makeKeyAndVisible()
        }
    }
    
    @objc
    func resignActive() {
//        if activeTime == nil || activeTime!.timeIntervalSinceNow < -5 {
//            control.center = CGPoint.init(x: 0, y: control.center.y)
//        }
    }
    
    // public APIS
    public static func shift() {
        ADKFloatingButton.sharedInstance.shift()
    }
    public static func expand() {
        ADKFloatingButton.sharedInstance.expand()
    }
    public static func shrink() {
        ADKFloatingButton.sharedInstance.shrink()
    }
}
