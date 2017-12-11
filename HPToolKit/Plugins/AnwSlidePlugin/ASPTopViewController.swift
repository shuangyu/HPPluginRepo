//
//  ASPTopViewController.swift
//  HPToolKit
//
//  Created by Hu, Peng on 30/11/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class ASPTopViewController: UIViewController, ASPSlideProtocol, ASPMessageReceiver
{

    private var maskView: UIView?
    public var parentController: ASPParentViewController {
        return self.parent as! ASPParentViewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\(#function)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\(#function)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("\(#function)")
    }
    
    @IBAction func slideOut(_ sender: Any?) {
        parentController.update(UIGestureRecognizerState.ended, with: 1.0)
    }
    
    open func sliding(with ratio: Float) {
    
        let translationRatio = parentController.config.translationRatio
        let scaleRatio = parentController.config.scaleRatio
        let w = Float(self.view.bounds.width)
        
        let t = CGAffineTransform.init(translationX: CGFloat(w * ratio * translationRatio), y: 0)
        let s = CGAffineTransform.init(scaleX: CGFloat(1 - scaleRatio * ratio), y: CGFloat(1 - scaleRatio * ratio))
        self.view.transform = t.concatenating(s)
    }
    
    open func finishSliding(with ratio: Float, completion block: @escaping ((Bool) -> Void)) {
        
        let _ratio = ratio >= 0.5 ? 1.0 : 0.0
        
        UIView.animate(withDuration: 0.25, animations: {
            self.sliding(with: Float(_ratio))
        }) {[unowned self] (finished: Bool) in
            if _ratio > 0.0 {
                
                if self.maskView != nil {
                    self.maskView?.removeFromSuperview()
                    self.maskView = nil
                }
                
                self.maskView = UIView.init(frame: self.view.bounds)
                self.maskView!.backgroundColor = UIColor.clear
                self.view.addSubview(self.maskView!)
                
                let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(self.handlePanGesture(_:)))
                self.maskView?.addGestureRecognizer(panGesture)
                
                let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapGesture(_:)))
                self.maskView?.addGestureRecognizer(tapGesture)
                
            } else {
                self.maskView?.removeFromSuperview()
                self.maskView = nil
            }
            block(_ratio > 0.0)
        }
    }
    
    @objc
    private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let vector = sender.translation(in: self.maskView)
        let ratio = Float(-vector.x)/parentController.maxTranslateDistance
        parentController.update(sender.state, with: 1 - ratio)
    }
    
    @objc
    private func handleTapGesture(_ sender: UIPanGestureRecognizer) {
        parentController.update(sender.state, with: 0.0)
    }
    
    // MARK: - ASPMessageSender
    open func asp_recevice(_ message: Any) {
        
    }

}
