//
//  ADKRootViewController.swift
//  AnwDebugKitDemo
//
//  Created by Hu, Peng on 24/10/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit


class ADKRootViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let configs = ADKContext.shared.config
    private lazy var configItems = ADKRootCellItem.parse(file: configs.rootPageConfigFileName)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configItems.append(contentsOf: configs.defaultItems)
    }
    
    @IBAction func dismissBtnClicked(_ sender: Any) {
        ADKFloatingButton.shrink()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: configs.rootPageCellReuseID)
        assert(cell != nil, "cell with reusable identifier \(configs.rootPageCellReuseID) not found")
        
        let title = configItems[indexPath.row].title
        assert(title != nil, "config item must contain \"title\" info")
        cell?.textLabel?.text = title
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellItem = configItems[indexPath.row]
        
        if let segueID = cellItem.segueID {
            self.performSegue(withIdentifier: segueID, sender: self)
        } else if let controller = try? cellItem.controller() {
            self.navigationController?.pushViewController(controller!, animated: true)
        }
    }
}
