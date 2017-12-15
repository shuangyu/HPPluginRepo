//
//  AnwPasswordDemoViewController.swift
//  HPToolKit
//
//  Created by Hu, Peng on 15/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class AnwPasswordDemoViewController: UIViewController {

    private var nineDotView: HPNineDotView = Bundle.main.loadNibNamed("HPNineDotView", owner: nil, options: nil)?.first as! HPNineDotView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Password View Demo"
        
        self.view.addSubview(nineDotView)
        nineDotView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        let insets = self.view.safeAreaInsets
        let topConstraint = NSLayoutConstraint.init(item: nineDotView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: insets.top)
        
        let bottomConstraint = NSLayoutConstraint.init(item: nineDotView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: insets.bottom)
        
        let leadingConstraint = NSLayoutConstraint.init(item: nineDotView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: insets.left)
        
        let trailingConstraint = NSLayoutConstraint.init(item: nineDotView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: insets.right)
        
        self.view.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
    
    
}
