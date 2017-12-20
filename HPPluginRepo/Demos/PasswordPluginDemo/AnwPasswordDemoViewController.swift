//
//  AnwPasswordDemoViewController.swift
//  HPPluginRepo
//
//  Created by Hu, Peng on 15/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class AnwPasswordDemoViewController: UIViewController, HPPasswordViewDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    private var nineDotView: HPNineDotView = Bundle.main.loadNibNamed("HPNineDotView", owner: nil, options: nil)?.first as! HPNineDotView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Password View Demo"
        
        let initalType = ADKPasswordViewSetting().initialType
        nineDotView.status = HPPasswordViewStatus(rawValue:initalType)!
        
        nineDotView.delegate = self
        self.view.insertSubview(nineDotView, belowSubview: statusLabel)
        nineDotView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        let insets = self.view.safeAreaInsets
        let topConstraint = NSLayoutConstraint(item: nineDotView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: insets.top)
        
        let bottomConstraint = NSLayoutConstraint(item: nineDotView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: insets.bottom)
        
        let leadingConstraint = NSLayoutConstraint(item: nineDotView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: insets.left)
        
        let trailingConstraint = NSLayoutConstraint(item: nineDotView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: insets.right)
        
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
                update(status: "Draw Again to Confirm")
            case .mismatch:
                update(status: "Mismatch! Please Try Again", with: true)
            case .match:
                update(status: "Pattern Saved")
                perform(#selector(closePage), with: nil, afterDelay: 1)
            default:
                break
            }
        } else if fromStatus == .reset {
            
            switch toStatus {
            case .empty:
                update(status: "Draw A New Pattern")
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
                update(status: "Pattern Deleted")
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
