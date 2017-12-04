//
//  RootViewController.swift
//  HPToolKit
//
//  Created by Hu, Peng on 30/11/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class RootViewController: UITableViewController {

//    private let dataSource = ["Debug Kit Demo", "Slide Plugin Demo"]
    private let dataSource = ["Debug Kit Demo"];
    private let segueIDs = ["openDebugKitPage", "openSlidePluginPage"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init event handler for ADK Demo
        ADKSettingCellEventCenter.register(eventHandler: ADKSettingEventHandler.init())

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            ADKFloatingButton.shift()
        } else {
            self.performSegue(withIdentifier: segueIDs[indexPath.row], sender: self)
        }
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: false)
    }
}
