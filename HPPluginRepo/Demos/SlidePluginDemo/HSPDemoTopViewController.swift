//
//  HSPDemoTopViewController.swift
//  HPPluginRepo
//
//  Created by Hu, Peng on 01/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class HSPDemoTopViewController: HSPTopViewController {

    @IBOutlet weak var menuBtn: UIButton!    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor.randomColor
    }

    @IBAction func dismissBtnClicked(_ sender: Any?) {
        self.parent?.dismiss(animated: true, completion: nil)
    }

    override func sliding(with ratio: Float) {
        super.sliding(with: ratio)
        menuBtn.alpha = CGFloat(1 - ratio)
    }
    
    override func asp_recevice(_ message: Any) {
        self.label.text = "item(\(message))"
    }
}
