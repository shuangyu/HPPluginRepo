//
//  ASPDemoTopViewController.swift
//  HPToolKit
//
//  Created by Hu, Peng on 01/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class ASPDemoTopViewController: ASPTopViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor.randomColor
    }

    @IBAction func dismissBtnClicked(_ sender: Any) {
        self.parent?.dismiss(animated: true, completion: nil)
    }
}
