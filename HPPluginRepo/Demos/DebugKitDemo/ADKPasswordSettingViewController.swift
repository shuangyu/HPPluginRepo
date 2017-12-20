//
//  ADKPasswordSettingViewController.swift
//  HPPluginRepo
//
//  Created by 胡鹏 on 20/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class ADKPasswordViewSettingCell: UITableViewCell {
    @IBOutlet weak var selectedLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectedLabel.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectedLabel.isHidden = !selected
    }
}

let viewTypeKey = "com.hpDemo.passwordViewSetting.viewTypeKey"
let initialTypeKey = "com.hpDemo.passwordViewSetting.initialTypeKey"

struct ADKPasswordViewSetting {
    let cache = UserDefaults.standard
    
    var viewType: Int {
        get {
            return cache.integer(forKey: viewTypeKey)
        }
        set(newValue) {
            cache.set(newValue, forKey: viewTypeKey)
        }
    }
    
    var initialType: Int {
        get {
            return cache.integer(forKey: initialTypeKey)
        }
        set(newValue) {
            cache.set(newValue, forKey: initialTypeKey)
        }
    }
}

class ADKPasswordSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let passwordViews = ["Nine Dot View"]
    let initialStatus = ["create", "reset", "delete", "verify"]
    var settings = ADKPasswordViewSetting()
    @IBOutlet weak var tableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.selectRow(at: IndexPath(row: settings.initialType, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.none)
    }

    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return section == 0 ? passwordViews.count : initialStatus.count
        return initialStatus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ADKPasswordViewSettingCell
        
//        if indexPath.section == 0 {
//            cell.textLabel?.text = passwordViews[indexPath.row]
////            cell.setSelected(settings.viewType == indexPath.row, animated: false)
//        } else {
            cell.textLabel?.text = initialStatus[indexPath.row]
            cell.setSelected(settings.initialType == indexPath.row, animated: false)
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        settings.initialType = indexPath.row
    }

}
