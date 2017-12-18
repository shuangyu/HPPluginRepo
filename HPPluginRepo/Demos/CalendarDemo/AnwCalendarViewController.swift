//
//  AnwCalendarViewController.swift
//  HPPluginRepo
//
//  Created by Hu, Peng on 11/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class AnwCalendarViewController: UIViewController {
    
    private var calendarView: HPCalendarView = Bundle.main.loadNibNamed("HPCalendarView", owner: nil, options: nil)?.first as! HPCalendarView
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calendar Demo"
        self.view.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false

    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        let insets = self.view.safeAreaInsets
        let topConstraint = NSLayoutConstraint.init(item: calendarView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: insets.top)
        
        let bottomConstraint = NSLayoutConstraint.init(item: calendarView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: insets.bottom)
        
        let leadingConstraint = NSLayoutConstraint.init(item: calendarView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: insets.left)
        
        let trailingConstraint = NSLayoutConstraint.init(item: calendarView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: insets.right)
        
        self.view.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
}
