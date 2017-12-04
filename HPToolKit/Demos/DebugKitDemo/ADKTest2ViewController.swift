//
//  ADKTest2ViewController.swift
//  AnwDebugKitDemo
//
//  Created by Hu, Peng on 26/10/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class ADKTest2ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        applyADKNavigationBar(title: "Test Page 2", backAction: #selector(backBtnClicked(_:)), dismissAction: #selector(dismissBtnClicked(_:)), theme: ADKContext.shared.theme)
        self.view.backgroundColor = UIColor.white
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    @IBAction func dismissBtnClicked(_ sender: Any) {
        ADKFloatingButton.shrink()
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
