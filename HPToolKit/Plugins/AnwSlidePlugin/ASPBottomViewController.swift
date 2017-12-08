//
//  ASPBottomViewController.swift
//  HPToolKit
//
//  Created by Hu, Peng on 30/11/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class ASPBottomViewController: UIViewController, ASPSlideProtocol, ASPMessageReceiver {

    private var maskView: UIView?
    private var parentController: ASPParentViewController {
        return self.parent as! ASPParentViewController
    }
    private var currentRatio: Float = 0.0
    private let oriAlpha: CGFloat = 0.6
    
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
    
    @IBAction func dismiss(_ sender: Any?) {
        parentController.update(UIGestureRecognizerState.ended, with: 0.0)
    }
    
    // MARK: - ASPSlideProtocol
    open func sliding(with ratio: Float) {
        if maskView == nil {
            maskView = UIView.init(frame: self.view.bounds)
            maskView!.backgroundColor = UIColor.black
            maskView!.alpha = oriAlpha
            parentController.view.insertSubview(maskView!, aboveSubview: self.view)
        }
        let translationRatio = 1 - parentController.config.translationRatio
        let scaleRatio = parentController.config.scaleRatio
        let w = Float(self.view.bounds.width)
        let _ratio = 1 - ratio
        
        let t = CGAffineTransform.init(translationX: CGFloat(-translationRatio * w * _ratio), y: 0)
        let s = CGAffineTransform.init(scaleX: CGFloat(1 - scaleRatio * _ratio), y: CGFloat(1 - scaleRatio * _ratio))
        
        self.view.transform = t.concatenating(s)
        
        maskView?.alpha = oriAlpha * CGFloat(_ratio)
        currentRatio = ratio
    }
    
    open func finishSliding(with ratio: Float, completion block: @escaping ((Bool) -> Void)) {
        let _ratio: Float = ratio >= 0.5 ? 1.0 : 0.0
        
        // if this animation is triggered by a tap gestrue,
        // we need to set up a intialized interface to
        // make this animation smooth.
        if maskView == nil {
            sliding(with: currentRatio)
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.sliding(with: _ratio)
        }) {[unowned self] (finished) in
            
            self.currentRatio = _ratio
            self.maskView?.removeFromSuperview()
            self.maskView = nil
            block(_ratio > 0.0)
        }
    }
    
    // MARK: - ASPMessageSender
    open func asp_recevice(_ message: Any) {
        
    }
}
