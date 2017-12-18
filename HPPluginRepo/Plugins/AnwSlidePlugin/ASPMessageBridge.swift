//
//  ASPMessageBridge.swift
//  HPPluginRepo
//
//  Created by Hu, Peng on 08/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

@objc
public protocol ASPMessageSender {
    func asp_send(_ message: Any)
    func asp_add(receiver: ASPMessageReceiver)
}

@objc
public protocol ASPMessageReceiver {
    func asp_recevice(_ message: Any)
}

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
            // use weak reference to avoid retain cycles
            objc_setAssociatedObject(self, &ASPAssociatedKeys.observerKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            guard let receiver = objc_getAssociatedObject(self, &ASPAssociatedKeys.observerKey) as? ASPMessageReceiver else {
                return nil
            }
            return receiver
        }
    }
    public func asp_add(receiver: ASPMessageReceiver) {
        self.asp_observer = receiver
    }

    // MARK: - ASPMessageSender
    
    public func asp_send(_ message: Any) {
        self.asp_observer?.asp_recevice(message)
    }
}

