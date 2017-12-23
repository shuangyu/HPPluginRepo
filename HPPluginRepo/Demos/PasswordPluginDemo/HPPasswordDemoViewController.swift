//
//  HPPasswordDemoViewController.swift
//  HPPluginRepo
//
//  Created by Hu, Peng on 15/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class HPPasswordDemoViewController: UIViewController, HPPasswordViewDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    let passwordViewType = UserDefaults.standard.integer(forKey: "APPPasswordViewTypeKey")
    
    private var passwordView: IHPPasswordView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = passwordViewType == 0 ? "HPNineDotView" : "HPSimplePasscodeView"
        self.title = passwordViewType == 0 ? "Nine Dot View Demo" : "Simple Passcode View Demo"
        passwordView = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)?.first as? IHPPasswordView
        let initalType = ADKPasswordViewSetting().initialType
        passwordView!.status = HPPasswordViewStatus(rawValue:initalType)!
        
        passwordView!.delegate = self
        
        self.view.insertSubview(passwordView as! UIView, belowSubview: statusLabel)
        (passwordView as! UIView).translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        let pwdView = passwordView as! UIView
        let insets = self.view.safeAreaInsets
        let topConstraint = NSLayoutConstraint(item: pwdView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: insets.top)
        
        let bottomConstraint = NSLayoutConstraint(item: pwdView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: insets.bottom)
        
        let leadingConstraint = NSLayoutConstraint(item: pwdView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: insets.left)
        
        let trailingConstraint = NSLayoutConstraint(item: pwdView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: insets.right)
        
        self.view.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
    
    private func update(status: String, with error: Bool = false) {
        statusLabel.text = status
        statusLabel.textColor = error ? UIColor.colorFrom(hex: "F26D5F") : UIColor.colorFrom(hex: "4E4749")
    }
    
    @objc
    private func closePage() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - HPPasswordViewDelegate
    
    func statusWill(change: HPPasswordViewStatusChange) {
        //...
        
        let fromStatus = change.from
        let toStatus = change.to
        let tryTimes = change.tryTimes
        
        if fromStatus == .create {
            switch toStatus {
            
            case .invalid:
                update(status: "Passcode length should be longger than 3", with: true)
            case .create:
                
                passwordViewType == 0 ? update(status: "Draw Again to Confirm") : update(status: "Input Again to Confirm")
            case .mismatch:
                update(status: "Mismatch! Please Try Again", with: true)
            case .match:
                passwordViewType == 0 ? update(status: "Pattern Saved") : update(status: "Passcode Saved")
                perform(#selector(closePage), with: nil, afterDelay: 1)
            default:
                break
            }
        } else if fromStatus == .reset {
            
            switch toStatus {
            case .match:
                passwordViewType == 0 ? update(status: "Draw A New Pattern") : update(status: "Input A New Passcode")
            case .mismatch:
                update(status: "Mismatch! Left Try Times \(tryTimes)", with: true)
                if tryTimes == 0 {
                    perform(#selector(closePage), with: nil, afterDelay: 1)
                }
            default:
                break
            }
        } else if fromStatus == .delete {
            switch toStatus {
            case .mismatch:
                update(status: "Mismatch! Left Try Times \(tryTimes)", with: true)
                if tryTimes == 0 {
                    perform(#selector(closePage), with: nil, afterDelay: 1)
                }
            case .match:
                passwordViewType == 0 ? update(status: "Pattern Deleted") : update(status: "Passcode Deleted")
                perform(#selector(closePage), with: nil, afterDelay: 1)
            default:
                break
            }
        } else if fromStatus == .verify {
            switch toStatus {
            case .mismatch:
            update(status: "Mismatch! Left Try Times \(tryTimes)", with: true)
            if tryTimes == 0 {
            perform(#selector(closePage), with: nil, afterDelay: 1)
            }
            case .match:
            update(status: "Unlocked")
            perform(#selector(closePage), with: nil, afterDelay: 1)
            default:
            break
            }
        }
        
    }
    
    func statusDid(change: HPPasswordViewStatusChange) {
        //
    }
    
    func beginInput<T>(passwordView: T) where T : IHPPasswordView {
        update(status: "Release Finger When Done")
    }
    
    func endInput<T>(passwordView: T) where T : IHPPasswordView {
        
    }
    
}
