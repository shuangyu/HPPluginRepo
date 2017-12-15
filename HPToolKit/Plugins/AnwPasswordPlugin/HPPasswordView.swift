//
//  HPPasswordView.swift
//  HPToolKit
//
//  Created by Hu, Peng on 14/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit


enum HPPasswordViewStatus {
    // initial status
    case create
    case reset
    case delete
    case verify
    // result status
    case mismatch
    case match
    case invalid
}

struct HPPasswordViewStatusChange {
    var from: HPPasswordViewStatus
    var to: HPPasswordViewStatus
    var tryTimes : Int = 0
}

protocol IHPPasswordView: NSObjectProtocol {
    
    var maxTryTime: Int { get }
    var status: HPPasswordViewStatus { get set }    // ==> current status
    var tmpPassword: String? { get set }            // ==> current inputted password
    weak var delegate: HPPasswordViewDelegate? { get set }
    /*
     * generate password image for some special password view type,
     * like 9 Dot View, for save sake
     * just return nil if don't need this method
     */
    func passwordImage() -> UIImage?
    func updateView(with change: HPPasswordViewStatusChange)
}

protocol HPPasswordViewDelegate: NSObjectProtocol {
    func statusWill(change: HPPasswordViewStatusChange)
    func statusDid(change: HPPasswordViewStatusChange)
}

protocol IHPPasswordStorage: NSObjectProtocol {
    
    var password: String? { get }
    
    func save(password: String)
    func deletePassword()
    
    /*
     * validate inputted password
     */
    func validate(password: Any?) -> Bool
    /*
     * convert inputted password to a string value
     * For example original inputted password of 9 Dot View
     * maybe an array of indeies, we need to convert it to string value to save
     */
    func password(from: Any?) -> String?
}
//
//class HPDefaultPasswordStorage: NSObject, IHPPasswordStorage {
//    
//    private override init() {}
//    
//    static let `default` = HPDefaultPasswordStorage.init()
//    
//    var password: String? {
//        return "111"
//    }
//    
//    func save(password: String) {
//        
//    }
//    
//    func deletePassword() {
//        
//    }
//    
//    func validate(password: Any?) -> Bool {
//        return password != nil
//    }
//    
//    func password(from: Any?) -> String? {
//        return from == nil ? nil : "\(String(describing: from))"
//    }
//}

class HPPasswordViewDecorator<T: IHPPasswordView, P: IHPPasswordStorage> {

    // use weak property to avoid retain recycle
    weak var passwordView: T?
    weak var storage: P?
    
    init(passwordView: T, storage: P) {
        self.passwordView = passwordView
        self.storage = storage
    }
    
    func triggerStatusChange(_ change: HPPasswordViewStatusChange) {
        var outChange = change
        let inputtedPwd = storage!.password(from: passwordView!.tmpPassword)
        let pwd = storage!.password
        let tryTimes = change.tryTimes
        
        if change.from == .create {
            if pwd == nil { // input first time
                outChange.to = storage!.validate(password: inputtedPwd) ? .create : .invalid
            } else { // input second time
                if pwd == inputtedPwd {
                    outChange.to = .match
                    storage!.save(password: inputtedPwd!)
                } else {
                    outChange.to = .mismatch
                }
            }
        } else if change.from == .reset {

            if pwd == inputtedPwd { // unlock first and succeed, then skip to create process
                outChange.to = .create
            } else { // unlock failed
                outChange.tryTimes = tryTimes + 1
                outChange.to = .mismatch
            }
        } else if change.from == .delete {
            
            if pwd == inputtedPwd {
                outChange.to = .match
                storage!.deletePassword()
            } else {
                outChange.tryTimes = tryTimes + 1
                outChange.to = .mismatch
            }
        } else if change.from == .verify {
            if pwd == inputtedPwd {
                outChange.to = .match
            } else {
                outChange.tryTimes = tryTimes + 1
                outChange.to = .mismatch
            }
        }
        passwordView!.delegate?.statusWill(change: outChange)
        passwordView!.updateView(with: outChange)
        passwordView!.delegate?.statusDid(change: outChange)
    }
}

