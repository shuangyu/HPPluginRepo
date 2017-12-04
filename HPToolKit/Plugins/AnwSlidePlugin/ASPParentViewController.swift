//
//  ASPParentViewController.swift
//  HPToolKit
//
//  Created by Hu, Peng on 30/11/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

public struct ASPAnimationConfig {
    var translationRatio: Float = 0.8
    var scaleRatio: Float = 0.2
}

public protocol ASPSlideProtocol {
    func sliding(with ratio: Float)
    func finishSliding(with ratio: Float, completion block: @escaping ((Bool) -> Swift.Void) )
}

class ASPEmptySegue: UIStoryboardSegue {
    
}

class ASPParentViewController: UIViewController {

    open var config = ASPAnimationConfig()
    open var topViewController: ASPTopViewController? {
        return nil
    }
    open var bottomViewController: ASPBottomViewController? {
        return nil
    }
    
    private var edgePan: UIScreenEdgePanGestureRecognizer?
    public var maxTranslateDistance: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgePan = UIScreenEdgePanGestureRecognizer.init(target: self, action: #selector(handleEdgePan(_:)))
        edgePan!.edges = UIRectEdge.left
        self.view.addGestureRecognizer(edgePan!)
        
        let width = Float(UIScreen.main.bounds.width)
        maxTranslateDistance = config.translationRatio * width
        
        assert(topViewController != nil, "no top view controller has been setted!!!")
        assert(bottomViewController != nil, "no bottom view controller has been setted!!!")
        
        self.quickAdd(childViewController: bottomViewController!)
        self.quickAdd(childViewController: topViewController!)
    }
    
    @objc
    private func handleEdgePan(_ sender: UIScreenEdgePanGestureRecognizer) {
        let vector = sender.translation(in: self.view)
        let ratio = Float(vector.x)/maxTranslateDistance
        update(sender.state, with: ratio)
    }
    
    public func update(_ state: UIGestureRecognizerState, with ratio: Float) {
        
        if state == .began {
            
            topViewController?.sliding(with: ratio)
            bottomViewController?.sliding(with: ratio)
            
            // ????
            if ratio <= 0.2 {
                bottomViewController?.viewWillAppear(true)
                topViewController?.viewWillDisappear(true)
            } else if ratio >= 0.8 {
                topViewController?.viewWillAppear(true)
                bottomViewController?.viewWillDisappear(true)
            }
            
        } else if state == .changed {
            
            topViewController?.sliding(with: ratio)
            bottomViewController?.sliding(with: ratio)
            
        } else {
            
            bottomViewController?.finishSliding(with: ratio, completion: { [unowned self](flag: Bool) in
                self.edgePan!.isEnabled = !flag
                flag ? self.bottomViewController?.viewDidAppear(true) : self.bottomViewController?.viewDidDisappear(true)
            })
            
            topViewController?.finishSliding(with: ratio, completion: { [unowned self](flag: Bool) in
                self.edgePan!.isEnabled = !flag
                flag ? self.topViewController?.viewDidDisappear(true) : self.topViewController?.viewDidAppear(true)
                
            })
        }
    }
}
