//
//  HDKSettingEventHandler.swift
//  AnwDebugKitDemo
//
//  Created by Hu, Peng on 01/11/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

@objcMembers
class HDKSettingEventHandler: NSObject {
    
    let cache = UserDefaults.standard
    var ADK_Demo_CachedText: String?
    var ADK_Demo_CachedBool: Bool = false
    var ADK_Demo_CachedFloat: Float = 0.0
    var ADK_NotDefaultTheme: Bool = false
    var ASP_ScaleRatio: Float = 0.0
    var APP_PasswordViewType: Int = 0
    override init() {
        super.init()
        
        ADK_Demo_CachedText = cache.string(forKey: "demoInputCellKey")
        ADK_Demo_CachedBool = cache.bool(forKey: "demoSwitchCellKey")
        ADK_Demo_CachedFloat = cache.float(forKey: "demoSliderCellKey")
        ADK_NotDefaultTheme = cache.bool(forKey: "ADKNotDefaultThemeKey")
        ASP_ScaleRatio = cache.float(forKey: "ASPScaleRatioKey")
        APP_PasswordViewType = cache.integer(forKey: "APPPasswordViewTypeKey")
        NotificationCenter.default.addObserver(forName: HDKFloatingButtonShrinkNotifName, object: nil, queue: nil) { [unowned self](notif) in
            self.save()
        }
    }
    
    private func save() {
        self.cache.set(self.ADK_Demo_CachedText, forKey: "demoInputCellKey")
        self.cache.set(NSNumber(value: self.ADK_Demo_CachedBool), forKey: "demoSwitchCellKey")
        self.cache.set(NSNumber(value: self.ADK_Demo_CachedFloat), forKey: "demoSliderCellKey")
        self.cache.set(NSNumber(value: self.ADK_NotDefaultTheme), forKey: "ADKNotDefaultThemeKey")
        self.cache.set(NSNumber(value: self.ASP_ScaleRatio), forKey: "ASPScaleRatioKey")
        self.cache.set(NSNumber(value: self.APP_PasswordViewType), forKey: "APPPasswordViewTypeKey")
    }
    
    // MARK: - AnwDebugKit Demo
    public func openDetailPage() {
        print("\(#file)-\(#function)")
    }
    
    public func inputValueChanged(_ newValue: String) {
        ADK_Demo_CachedText = newValue
    }
    
    public func inputCellDefaultValue() -> String {
        
        if ADK_Demo_CachedText == nil {
            ADK_Demo_CachedText = "INPUT CELL DEFAULT VALUE"
        }
        return ADK_Demo_CachedText!
    }
    
    public func switchValueChanged(_ newValue: NSNumber) {
        ADK_Demo_CachedBool = newValue.boolValue
    }
    
    public func switchCellDefaultValue() -> NSNumber {
        return NSNumber(value: ADK_Demo_CachedBool)
    }
    
    public func sliderValueChanged(_ newValue: NSNumber) {
        ADK_Demo_CachedFloat = newValue.floatValue
    }
    
    public func sliderCellDefaultValue() -> NSNumber {
        return NSNumber(value: ADK_Demo_CachedFloat)
    }
    
    // async cell action will run async thread
    public func asyncProcess() {
        sleep(5)
        print("\(#file)-\(#function)")
    }
    
    // MARK: - AnwDebugKit Settings
    
    public func toggleTheme(_ newValue: NSNumber) {
        ADK_NotDefaultTheme = !newValue.boolValue
        
        self.save()
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (actionItem) in
            exit(0)
        }
        let controller = UIAlertController(title: "Tips", message: "You need to restart app to apply this change", preferredStyle: UIAlertControllerStyle.alert)
        controller.addAction(okAction)
        UIApplication.shared.keyWindow!.rootViewController!.present(controller, animated: true) {
            
        }
    }
    
    public func isDefaultTheme() -> NSNumber {
        return NSNumber(value: !ADK_NotDefaultTheme)
    }
    
    // MARK: - AnwDebugKit Settings

    public func setScaleRatio(_ newValue: NSNumber) {
        ASP_ScaleRatio = newValue.floatValue
    }

    public func getScaleRatio() -> NSNumber {
        return NSNumber(value: ASP_ScaleRatio)
    }
    
    // MARK: - HPPasswordView Demo Settings

    public func passwordViewChanged(_ newValue: NSNumber) {
        APP_PasswordViewType = newValue.intValue
    }
    public func passwordViewType() -> NSNumber {
        return NSNumber(value: APP_PasswordViewType)
    }
    
    public func getPassword() -> String {
        
        let pwd = APP_PasswordViewType == 0 ? HPNineDotViewStorage().password : HPSimplePasscodeViewStorage().password
        guard pwd != nil else {
            return "no password"
        }
        
        return "password is: \(pwd!)"
    }
    
    public func openPasswodViewSettingPage() {
        let passwordVC = HDKPasswordSettingViewController.loadFromStoryboard("HDKStoryboard_phone")
        
        let navigationVC = UIApplication.shared.keyWindow!.rootViewController as! UINavigationController
        
        navigationVC.pushViewController(passwordVC, animated: true)
        
    }
}
