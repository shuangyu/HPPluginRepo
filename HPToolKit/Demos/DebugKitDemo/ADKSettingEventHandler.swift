//
//  ADKSettingEventHandler.swift
//  AnwDebugKitDemo
//
//  Created by Hu, Peng on 01/11/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

@objcMembers
class ADKSettingEventHandler: NSObject {
    
    let cache = UserDefaults.standard
    var cachedText: String?
    var cachedBool: Bool = false
    var cachedFloat: Float = 0.0
    
    override init() {
        super.init()
        
        cachedText = cache.string(forKey: "demoInputCellKey")
        cachedBool = cache.bool(forKey: "demoSwitchCellKey")
        cachedFloat = cache.float(forKey: "demoSliderCellKey")
        
        NotificationCenter.default.addObserver(forName: ADKFloatingButtonShrinkNotifName, object: nil, queue: nil) { [unowned self](notif) in
            self.cache.set(self.cachedText, forKey: "demoInputCellKey")
            self.cache.set(NSNumber.init(value: self.cachedBool), forKey: "demoSwitchCellKey")
            self.cache.set(NSNumber.init(value: self.cachedFloat), forKey: "demoSliderCellKey")
        }
    }
    
    public func openDetailPage() {
        print("\(#file)-\(#function)")
    }
    
    public func inputValueChanged(_ newValue: String) {
        cachedText = newValue
    }
    
    public func inputCellDefaultValue() -> String {
        
        if cachedText == nil {
            cachedText = "INPUT CELL DEFAULT VALUE"
        }
        return cachedText!
    }
    
    public func switchValueChanged(_ newValue: NSNumber) {
        cachedBool = newValue.boolValue
    }
    
    public func switchCellDefaultValue() -> NSNumber {
        return NSNumber.init(value: cachedBool)
    }
    
    public func sliderValueChanged(_ newValue: NSNumber) {
        let float = newValue.floatValue
        let str = String(format:"%.1f", float)
        cachedFloat = Float.init(str)!
    }
    
    public func sliderCellDefaultValue() -> NSNumber {
        return NSNumber.init(value: 0.3)
    }
    
    // async cell action will run async thread
    public func asyncProcess() {
        sleep(5)
        print("\(#file)-\(#function)")
    }
    
    deinit {
       
    }
}
