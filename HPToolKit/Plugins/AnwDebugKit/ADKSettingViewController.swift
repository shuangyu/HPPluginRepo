//
//  ADKSettingViewController.swift
//  AnwDebugKitDemo
//
//  Created by Hu, Peng on 30/10/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

public var _eventHandlers = Array<NSObject>()

public class ADKSettingCellEventCenter {
    
    public static let sharedInstance = ADKSettingCellEventCenter()
    
    private init() {}
    
    public static func register(eventHandler : NSObject) {
        
        for handler in _eventHandlers {
            if type(of: handler) === type(of: eventHandler) {
                return
            }
        }
        _eventHandlers.append(eventHandler)
    }
    
    @discardableResult
    func handleEvent(with selectorName: String, params: Any? = nil, callback:((AnyObject?) -> Swift.Void)? = nil) -> Unmanaged<AnyObject>! {
        
        let selector = NSSelectorFromString(selectorName)
        for eventHandler in _eventHandlers {
            if !eventHandler.responds(to: selector) {
                continue
            }
            
            if callback != nil {
                DispatchQueue.global(qos: .userInitiated).async {
                    // TBD : may cause some leak if result is a retained object
                    let result = eventHandler.perform(selector) != nil ? eventHandler.perform(selector).takeUnretainedValue() : nil
                    DispatchQueue.main.async {
                        callback!(result)
                    }
                }
                return nil
            } else {
                return eventHandler.perform(selector, with: params)
            }
    
        }
        return nil
    }
}

class ADKSettingCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var sliderControl: UISlider!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    private var cellItem: ADKSettingCellItem?
    
    @IBAction func valueChanged(_ sender: AnyObject) {
        var value = NSNumber.init(value: 0)
        if let control = sender as? UISwitch {
            value = NSNumber.init(value: control.isOn)
        } else if let control = sender as? UISlider {
            value = NSNumber.init(value: control.value)
        }
        ADKSettingCellEventCenter.sharedInstance.handleEvent(with: cellItem!.action!, params: value)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configCell(with cellItem: ADKSettingCellItem) {
        self.cellItem = cellItem
        if titleLabel != nil {
            titleLabel.text = cellItem.title
        }
        switch cellItem.type! {
        case .inputValue:
            let placeHolder =  ADKSettingCellEventCenter.sharedInstance.handleEvent(with: cellItem.defaultValue!).takeUnretainedValue() as! String
            textField.text = placeHolder
        case .switchValue:
            let isOn =  ADKSettingCellEventCenter.sharedInstance.handleEvent(with: cellItem.defaultValue!).takeUnretainedValue() as! NSNumber
            switchControl.isOn = isOn.boolValue
        case .sliderValue:
            let value =  ADKSettingCellEventCenter.sharedInstance.handleEvent(with: cellItem.defaultValue!).takeUnretainedValue() as! NSNumber
            sliderControl.value = value.floatValue
        case .async:
            cellItem.processing ? indicatorView.startAnimating() : indicatorView.stopAnimating()
        default:
            break
        }
    }
    
    func handleEvent() {
        switch cellItem!.type! {
        case .async:
            cellItem!.processing = true
            indicatorView.startAnimating()
            ADKSettingCellEventCenter.sharedInstance.handleEvent(with: cellItem!.action!, callback:{
                [unowned self] (result) in
                self.indicatorView.stopAnimating()
            })
        case .detail:
            ADKSettingCellEventCenter.sharedInstance.handleEvent(with: cellItem!.action!)
        default:
            break
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        ADKSettingCellEventCenter.sharedInstance.handleEvent(with: cellItem!.action!, params: textField.text)
    }
}


class ADKSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let config = ADKContext.shared.config
    private lazy var items: (sections: Array<ADKSettingCellItem>, rows: Array<Array<ADKSettingCellItem>>) = ADKSettingCellItem.parse(file: config.settingPageConfigFileName)
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = items.sections[section]
        return section.title
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = items.rows
        return rows[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rows = items.rows[indexPath.section]
        let item = rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.type!.rawValue) as! ADKSettingCell
        cell.configCell(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ADKSettingCell
        cell.handleEvent()
    }
}
