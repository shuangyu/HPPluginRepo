//
//  HDKExtension.swift
//  AnwDebugKitDemo
//
//  Created by Hu, Peng on 24/10/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

let navBarHeight: Int = 64

public extension UIViewController {
    
    public func applyADKNavigationBar(title: String, backAction: Selector?, dismissAction: Selector?, theme: ADKTheme) {
    
        let w = Int(UIScreen.main.bounds.width)
        let h = navBarHeight
        let leftMargin = 12
        let topMargin = 26
        let navBar = UIView(frame: CGRect(x: 0, y: 0, width: w, height: h))
        navBar.backgroundColor = theme.mainColor
        navBar.autoresizingMask = UIViewAutoresizing.flexibleWidth
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = theme.fontColor
        titleLabel.font = UIFont.systemFont(ofSize: 17.0)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x :w / 2, y: 20 + (h - 20) / 2)
        titleLabel.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleLeftMargin.rawValue | UIViewAutoresizing.flexibleRightMargin.rawValue)
        navBar.addSubview(titleLabel)
        
        if backAction != nil {
            let backBtn = UIButton(type: UIButtonType.custom)
            backBtn.frame = CGRect(x: leftMargin, y: topMargin, width: 0, height: 0)
            backBtn.titleLabel?.textColor = theme.fontColor
            backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
            backBtn.setTitle("Back", for: UIControlState.normal)
            backBtn.autoresizingMask = UIViewAutoresizing.flexibleRightMargin
            backBtn.addTarget(self, action: backAction!, for: UIControlEvents.touchUpInside)
            backBtn.sizeToFit()
            navBar.addSubview(backBtn)
        }
        
        if dismissAction != nil {
            let dismissBtn = UIButton(type: UIButtonType.custom)
            dismissBtn.titleLabel?.textColor = theme.fontColor
            dismissBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
            dismissBtn.setTitle("Dismiss", for: UIControlState.normal)
            dismissBtn.autoresizingMask = UIViewAutoresizing.flexibleLeftMargin
            dismissBtn.addTarget(self, action: dismissAction!, for: UIControlEvents.touchUpInside)
            dismissBtn.sizeToFit()
            dismissBtn.frame = CGRect(x: w - leftMargin - Int(dismissBtn.bounds.width), y: topMargin, width: Int(dismissBtn.bounds.width), height: Int(dismissBtn.bounds.height))
            navBar.addSubview(dismissBtn)
        }
        
        self.view.addSubview(navBar)
    }
}

