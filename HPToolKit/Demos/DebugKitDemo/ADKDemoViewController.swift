//
//  ADKDemoViewController.swift
//  HPToolKit
//
//  Created by Hu, Peng on 30/11/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit


class ADKDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Debug Kit Demo"
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tap(_:)))
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func tap(_ sender: Any) {
        ADKFloatingButton.shift()
    }
}
