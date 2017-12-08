//
//  ASPMessageBridge.swift
//  HPToolKit
//
//  Created by Hu, Peng on 08/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

@objc
public protocol ASPMessageSender {
    func asp_send(_ message: Any)
}

@objc
public protocol ASPMessageReceiver {
    func asp_recevice(_ message: Any)
}

//class ASPMessageBridge<T: ASPMessageSender, P: ASPMessageReceiver>: NSObject {
//
//    unowned let sender: T
//    unowned let receiver: P
//    init(sender: T, receiver: P) {
//        self.sender = sender
//        self.receiver = receiver
//        super.init()
//        self.methodHook()
//    }
//
//    private func methodHook() {
//        let originalSelector = #selector(sender.send(_:))
//        let swizzledSelector = #selector(self.hook_send(_:))
//        let originalMethod = class_getInstanceMethod(type(of: sender), originalSelector)
//        let swizzledMethod = class_getInstanceMethod(type(of: self), swizzledSelector)
//        method_exchangeImplementations(originalMethod!, swizzledMethod!)
//    }
//    @objc
//    private func hook_send(_ message: Any) {
//        self.hook_send(message)
//        self.receiver.recevice(message)
//    }
//}

struct ASPAssociatedKeys {
    static var observerKey: UInt8 = 0
}

extension UIViewController: ASPMessageSender {
    
    private(set) var asp_observer: ASPMessageReceiver? {
        set(newValue) {
            guard let value = newValue else {
                objc_removeAssociatedObjects(self)
                return
            }
            objc_setAssociatedObject(self, &ASPAssociatedKeys.observerKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            guard let receiver = objc_getAssociatedObject(self, &ASPAssociatedKeys.observerKey) as? ASPMessageReceiver else {
                return nil
            }
            return receiver
        }
    }
    public func asp_add(observer: ASPMessageReceiver?) {
        self.asp_observer = observer
    }

    // MARK: - ASPMessageSender
    
    public func asp_send(_ message: Any) {
        self.asp_observer?.asp_recevice(message)
    }
}

