//
//  HSPDemoParentViewController.swift
//  HPPluginRepo
//
//  Created by Hu, Peng on 01/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class HSPDemoParentViewController: HSPParentViewController {
    
    weak private var _topViewController: HSPTopViewController?
    weak private var _bottomViewController: HSPBottomViewController?
    
    override var config: ASPAnimationConfig {
        return ASPAnimationConfig(scaleRatio: appSettings.ASPScaleRatio)
    }
    override var topViewController: HSPTopViewController? {
        
        if _topViewController == nil {
            _topViewController =  HSPDemoTopViewController.loadFromStoryboard() as? HSPTopViewController
        }
        return _topViewController
    }
    override var bottomViewController: HSPBottomViewController? {
        if _bottomViewController == nil {
            _bottomViewController = HSPDemoBottomViewController.loadFromStoryboard() as? HSPBottomViewController
        }
        return _bottomViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
