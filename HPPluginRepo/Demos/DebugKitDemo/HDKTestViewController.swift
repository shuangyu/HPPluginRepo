//
//  HDKTestViewController.swift
//  AnwDebugKitDemo
//
//  Created by Hu, Peng on 26/10/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class HDKTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction func dismissBtnClicked(_ sender: Any) {
        HDKFloatingButton.shrink()
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
