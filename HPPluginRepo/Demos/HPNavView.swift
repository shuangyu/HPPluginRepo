//
//  HPNavView.swift
//  HPPluginRepo
//
//  Created by Hu, Peng on 11/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class HPNavView: UIView {
    @IBOutlet weak var heightConstraint: NSLayoutConstraint?
    override func awakeFromNib() {
        super.awakeFromNib()
        let screentH = UIScreen.main.bounds.height
        if (screentH == 812 || screentH == 896) {
            heightConstraint?.constant = 84
        } else {
            heightConstraint?.constant = 64
        }
        updateConstraintsIfNeeded()
    }
}
