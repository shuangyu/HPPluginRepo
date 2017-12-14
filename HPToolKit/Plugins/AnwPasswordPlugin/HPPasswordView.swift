//
//  HPPasswordView.swift
//  HPToolKit
//
//  Created by Hu, Peng on 14/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

enum HPPasswordViewStatus {
    case create
    case reset
    case delete
    case verify
    case mismatch
    case match
}

struct HPPasswordViewStatusChange {
    var from: HPPasswordViewStatus
    var to: HPPasswordViewStatus
    var tryTimes : Int
}

//@objc
protocol IHPPasswordView : NSObjectProtocol {
    
    var maxTryTime: Int { get }
    var status: HPPasswordViewStatus { get set }    // ==> current status
    var tmpPassword: String? { get set }
    /*
     * generate password image for some special password view type,
     * like 9 Dot View, for save sake
     * just return nil if don't need this method
     */
    func passwordImage() -> UIImage?
}

protocol HPPasswordViewDelegate {
    func statusWill(change: HPPasswordViewStatusChange)
    func statusDid(change: HPPasswordViewStatusChange)
}

protocol IHPPasswordStorage : NSObjectProtocol {
    
    var password: String? { get }
    
    func save(password: String)
    func deletePassword()
    
    //
    // convert input password to a string value
    //
    func password(from: Any?) -> String?
}

class HPDefaultPasswordStorage: NSObject, IHPPasswordStorage {
    
    private override init() {}
    
    static let `default` = HPDefaultPasswordStorage.init()
    
    var password: String? {
        return "111"
    }
    
    func save(password: String) {
        
    }
    
    func deletePassword() {
        
    }
    
    func password(from: Any?) -> String? {
        return from == nil ? nil : "\(String(describing: from))"
    }
}

class HPPasswordViewDecorator<T: IHPPasswordView, P: IHPPasswordStorage> {

    // use weak property to avoid retain recycle
    weak var passwordView: T?
    weak var storage: P?
    
    init(passwordView: T, storage: P) {
        self.passwordView = passwordView
        self.storage = storage
    }
    
    func triggerStatusChange() {
        
        
        
    }
}

