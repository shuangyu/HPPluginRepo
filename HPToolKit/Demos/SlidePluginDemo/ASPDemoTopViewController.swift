//
//  ASPDemoTopViewController.swift
//  HPToolKit
//
//  Created by Hu, Peng on 01/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class ASPDemoTopViewController: ASPTopViewController {

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = UIColor.randomColor
        self.parent?.title = "Main"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let parentVC = self.parentController as! ASPDemoParentViewController
//       parentVC.menuBtn
    }

    override func asp_recevice(_ message: Any) {
        self.label.text = "item(\(message))"
    }
}
