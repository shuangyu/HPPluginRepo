//
//  ASPDemoParentViewController.swift
//  HPToolKit
//
//  Created by Hu, Peng on 01/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class ASPDemoParentViewController: ASPParentViewController {
    
    override var config: ASPAnimationConfig {
        return ASPAnimationConfig.init(scaleRatio: appSettings.ASPScaleRatio)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    private var _topViewController: ASPTopViewController?
    private var _bottomViewController: ASPBottomViewController?
    
    override var topViewController: ASPTopViewController? {
        
        if _topViewController == nil {
            _topViewController =  ASPDemoTopViewController.loadFromStoryboard() as? ASPTopViewController
        }
        return _topViewController
    }
    
    override var bottomViewController: ASPBottomViewController? {
        if _bottomViewController == nil {
            _bottomViewController = ASPDemoBottomViewController.loadFromStoryboard() as? ASPBottomViewController
        }
        return _bottomViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
