//
//  ASPDemoBottomViewController.swift
//  HPToolKit
//
//  Created by Hu, Peng on 01/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class ASPDemoBottomViewController: ASPBottomViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - table view delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = "Item \(indexPath.row)"
        return cell!
    }
    
    
}
