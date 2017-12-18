//
//  DemoAppContext.swift
//  HPPluginRepo
//
//  Created by Hu, Peng on 05/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//
import UIKit

public struct DemoAppSettings {
    var ADKUserDefaultTheme: Bool {
        return !UserDefaults.standard.bool(forKey: "ADKNotDefaultThemeKey")
    }
    
    var ASPScaleRatio: Float {
        return UserDefaults.standard.float(forKey: "ASPScaleRatioKey")
    }
}

public let appSettings = DemoAppSettings()
