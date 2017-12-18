//
//  HPPasswordView.swift
//  HPPluginRepo
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
    case empty
    // result status
    case mismatch
    case match
    case invalid
    
}

struct HPPasswordViewStatusChange {
    var from: HPPasswordViewStatus
    var to: HPPasswordViewStatus
    var tryTimes : Int
    init(from: HPPasswordViewStatus, to: HPPasswordViewStatus = .empty, tryTimes: Int = Int.max) {
        self.from = from
        self.to = to
        self.tryTimes = tryTimes
    }
}

protocol IHPPasswordView: NSObjectProtocol {
    
    var maxTryTime: Int { get }
    var status: HPPasswordViewStatus { get set }    // ==> current status
    var tmpPassword: Any? { get set }            // ==> current inputted password
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
    // called before password view updateView(with change: HPPasswordViewStatusChange)
    func statusWill(change: HPPasswordViewStatusChange)
    // called after password view updateView(with change: HPPasswordViewStatusChange)
    func statusDid(change: HPPasswordViewStatusChange)
    
    func beginInput<T: IHPPasswordView>(passwordView: T)
    func endInput<T: IHPPasswordView>(passwordView: T)
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

class HPPasswordViewDecorator<T: IHPPasswordView, P: IHPPasswordStorage> {

    // use weak property to avoid retain recycle
    weak var passwordView: T?
    var storage: P?
    var tmpPwd: String?
    
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
            if tmpPwd == nil { // input first time
                let validePwd = storage!.validate(password: passwordView!.tmpPassword)
                outChange.to = validePwd ? .create : .invalid
                if validePwd {
                    tmpPwd = inputtedPwd
                }
            } else { // input second time
                if tmpPwd == inputtedPwd {
                    outChange.to = .match
                    storage!.save(password: inputtedPwd!)
                } else {
                    tmpPwd = nil
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

