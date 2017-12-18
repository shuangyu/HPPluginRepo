//
//  ADKTheme.swift
//  AnwDebugKitDemo
//
//  Created by Hu, Peng on 23/10/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

enum ADKError : Error {
    case invalidClassName(className: String)
    case invalidSelectorName(selectorName: String)
}

enum ADKCellType : String {
    case groupHeader = "ADKCellTypeGroupHeader"
    case plain  = "ADKCellTypePlain"
    case detail = "ADKCellTypeDetail"
    case async  = "ADKCellTypeAsync"
    case inputValue  = "ADKCellTypeInput"
    case switchValue = "ADKCellTypeSwitch"
    case sliderValue = "ADKCellTypeSlider"
}

public struct ADKRootCellItem {
    var title: String?               // ===> item title displayed on the cell
    var segueID: String?             // ===> id of segue which connected to this controller in the root storyboard
    var controllerName: String?      // ===> class name of this controller
    var controllerID: String?        // ===> stoaryboard id of this controller
    // ===> stoaryboard name which contains this controller
    var controllerContainer : String? = ADKContext.shared.config.storyboardName
    
    func controller () throws -> UIViewController? {
        if controllerName != nil {
            guard let clz = NSClassFromString(controllerName!) else {
                throw ADKError.invalidClassName(className: controllerName!)
            }
            let controllerClz = clz as! UIViewController.Type
            return controllerClz.init()
        } else if controllerID != nil {
            let sb = UIStoryboard(name: controllerContainer!, bundle: nil)
            return sb.instantiateViewController(withIdentifier: controllerID!)
        } else {
            return nil
        }
    }

    init(title: String?, segueID: String?, controllerName: String?, controllerID: String? ,controllerContainer: String?) {
        self.title = title
        self.segueID = segueID
        self.controllerName = controllerName
        self.controllerID = controllerID
        self.controllerContainer = controllerContainer
    }
    
    static func parse(file: String) -> Array<ADKRootCellItem> {
        let path = Bundle.main.path(forResource: file, ofType: "plist")
        assert(path != nil, "config file [\(file)] not found")
        let rawItems = NSArray(contentsOfFile: path!)
        var items = Array<ADKRootCellItem>()
        
        for rawItem in rawItems! {
            let rawItemInfo: NSDictionary = rawItem as! NSDictionary
            let item = ADKRootCellItem(title: (rawItemInfo["title"] as? String),
                                         segueID: (rawItemInfo["segueID"] as? String),
                                         controllerName: (rawItemInfo["controllerName"] as? String),
                                         controllerID: nil,
                                         controllerContainer: nil)
            items.append(item)
        }
        return items
    }
}

public struct ADKSettingCellItem {
    var title: String?          // ===> cell title
    var action: String?         // ===> string value of cell action selector
    var type: ADKCellType?      // ===> cell type
    var defaultValue: String?   // ===> string value of cell default value selector
    var processing = false      // ===> only used for async cell type
    
    static func parse(file: String) -> (sections: Array<ADKSettingCellItem>, rows: Array<Array<ADKSettingCellItem>>) {
        let path = Bundle.main.path(forResource: file, ofType: "plist")
        assert(path != nil, "config file [\(file)] not found")
        let rawSections = NSArray(contentsOfFile: path!)
        
        guard rawSections != nil else {
            return ([], [])
        }
        
        var rows = Array<Array<ADKSettingCellItem>>()
        var sections = Array<ADKSettingCellItem>()
        
        for rawSection in rawSections! {
            
            let rawSectionInfo: NSDictionary = rawSection as! NSDictionary
            var section = ADKSettingCellItem()
            section.title = rawSectionInfo["title"] as? String
            section.type = ADKCellType(rawValue: rawSectionInfo["type"] as! String)
            
            let rawRows: NSArray? = rawSectionInfo["items"] as? NSArray
            var sectionRows = Array<ADKSettingCellItem>()
            
            if rawRows != nil {
                for rawRow in rawRows! {
                    let rawRowInfo: NSDictionary = rawRow as! NSDictionary
                    var item = ADKSettingCellItem()
                    item.title = rawRowInfo["title"] as? String
                    item.action = rawRowInfo["action"] as? String
                    item.type = ADKCellType(rawValue: rawRowInfo["type"] as! String)
                    item.defaultValue = rawRowInfo["defaultValue"] as? String
                    sectionRows.append(item)
                }
            }
            sections.append(section)
            rows.append(sectionRows)
        }
        return (sections: sections, rows: rows)
    }
}

public let settingItem = ADKRootCellItem(title: "Settings",
                                         segueID: nil,
                                         controllerName: nil,
                                         controllerID: "ADKSettingViewController",
                                         controllerContainer: "ADKStoryboard_container")

public let guideItem = ADKRootCellItem(title: "Guide",
                                       segueID: nil,
                                       controllerName: nil,
                                       controllerID: "ADKGuideViewController",
                                       controllerContainer: "ADKStoryboard_container")


public protocol ADKTheme {
    var description: String { get }
    var mainColor: UIColor { get }
    var fontColor: UIColor { get }
    var floatingButtonSize: CGSize { get }
    var floationButtonColor: UIColor { get }
    var floatingButtonText: String { get }
    var floationButtonTextColor: UIColor { get }
    var floationButtonFontSize: CGFloat { get }
}

public protocol ADKConfig {
    var storyboardName_phone: String { get }
    var storyboardName_pad: String { get }
    var rootPageConfigFileName: String { get }
    var settingPageConfigFileName: String { get }
    
    var storyboardName: String { get }
    var storyboard: UIStoryboard { get }
    var rootPageCellReuseID: String { get }
    var defaultItems: Array<ADKRootCellItem> { get }
}

public struct ADKDefaultConfig: ADKConfig {
    public var storyboardName_phone: String {
        return "ADKStoryboard_phone"
    }
    public var storyboardName_pad: String {
        return "ADKStoryboard_pad"
    }
    public var rootPageConfigFileName: String {
        return "ADKRootConfig"
    }
    public var settingPageConfigFileName: String {
        return "ADKSettingConfig"
    }
    public var storyboardName: String {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? storyboardName_pad : storyboardName_phone
    }
    public var storyboard: UIStoryboard {
        return  UIStoryboard(name: storyboardName, bundle: nil)
    }
    public var rootPageCellReuseID: String {
        return "cell"
    }
    public var defaultItems: Array<ADKRootCellItem> {
        return [guideItem ,settingItem]
    }
}

public struct ADKDefaultTheme : ADKTheme {
    
    public var description: String {
        return "ADKDefaultTheme"
    }
    public var mainColor: UIColor {
        return UIColor(red: 137.0/255.0, green: 49.0/255.0, blue: 234.0/255.0, alpha: 1.0)
    }
    public var fontColor: UIColor {
        return UIColor.white
    }
    public var floatingButtonSize: CGSize {
        return CGSize(width: 60, height: 60)
    }
    public var floationButtonColor: UIColor {
        return UIColor(red: 137.0/255.0, green: 49.0/255.0, blue: 234.0/255.0, alpha: 1.0)
    }
    public var floatingButtonText: String {
        return NSLocalizedString("Debug", comment: self.description)
    }
    public var floationButtonTextColor: UIColor {
        return UIColor.white
    }
    public var floationButtonFontSize: CGFloat {
        return 14.0
    }
}

public class ADKContext {
    public static let shared = ADKContext()
    public var theme: ADKTheme = ADKDefaultTheme()
    public var config: ADKConfig = ADKDefaultConfig()
    private init() {}
}
