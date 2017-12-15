//
//  HPNineDotView.swift
//  HPToolKit
//
//  Created by Hu, Peng on 15/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

let kNDVMainColor = UIColor.color255(from: (r: 91.0, g: 153.0, b: 238.0, a: 1.0))
let kNDVSelectedBorderColor = UIColor.color255(from: (r: 53.0, g: 183.0, b: 127.0, a: 1.0))
let kNDVErrorLineColor = UIColor.color255(from: (r: 53.0, g: 183.0, b: 127.0, a: 1.0))

@IBDesignable
open class HPNineDotView: UIView, IHPPasswordView {
    
    // UI Var.
    @IBInspectable var dotRadius: CGFloat = 30
    @IBInspectable var dotMargin: CGFloat = 30
    @IBInspectable var dotBordrrWidth: CGFloat = 1
    @IBInspectable var dotBorderColor: UIColor = kNDVMainColor
    @IBInspectable var dotSelectedBorderColor: UIColor = kNDVSelectedBorderColor
    
    
    @IBInspectable var connectLineWidth: CGFloat = 1
    @IBInspectable var connectLineColor: UIColor = kNDVMainColor
    @IBInspectable var errorConnectLineColor: UIColor = kNDVErrorLineColor
    
    
    @IBOutlet weak var _maskView: UIImageView!
    private var staticImage: UIImage?
    private var seletedIndies: Array<Int> = []
    
    // Logic Var.
    private var dotRects: Array<CGRect> = []
    private var prePoint: CGPoint?
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let point = touch.location(in: self)
        
        let index = selectedDot(with: point)

        guard index != NSNotFound else {
            return
        }
        selectDot(at: index)
        prePoint = dotRects[index].center
        
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let startPoint = prePoint else {
            return
        }
        
        let touch = touches.first!
        let point = touch.location(in: self)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()!
        for i in 0..<9 {
            let center = centerOfDot(at: i)
            draw(dot: (radius: CGFloat(dotRadius), center: center), with: context)
            dotRects.append(CGRect.rectOfCircle(center: center, radius: dotRadius))
        }
        staticImage = UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    // MARK: - IHPPasswordView implementation
    var maxTryTime: Int {
        return 3
    }
    
    var status: HPPasswordViewStatus = .create
    
    var tmpPassword: String?
    
    var delegate: HPPasswordViewDelegate?
    
    func passwordImage() -> UIImage? {
        return nil
    }
    
    func updateView(with change: HPPasswordViewStatusChange) {
        
    }
    
    // MARK: -
    
    private func centerOfDot(at index: Int) -> CGPoint {
        let w = self.bounds.width
        let h = self.bounds.height
        
        let viewCenter = CGPoint.init(x: w/2.0, y: h/2.0)
        let viewCenterRow = 1
        let viewCenterColumn = 1
        
        let row = index/3
        let column = index%3
        
        let x = viewCenter.x + CGFloat(row - viewCenterRow) * (dotRadius * 2 + dotMargin)
        let y = viewCenter.y + CGFloat(column - viewCenterColumn) * (dotRadius * 2 + dotMargin)
        return CGPoint.init(x: x, y: y)
    }
    
    open func draw(dot: (radius: CGFloat, center: CGPoint), with context: CGContext) {
        context.addArc(center: dot.center, radius: dot.radius, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: false)
        context.setStrokeColor(dotBorderColor.cgColor)
        context.setLineWidth(dotBordrrWidth)
        context.strokePath()
    }
    

    private func selectedDot(with touchPoint:CGPoint) -> Int {
        for dotRect in dotRects {
            if dotRect.contains(touchPoint) {
                return dotRects.index(of: dotRect)!
            }
        }
        return NSNotFound
    }
    
    private func selectDot(at index: Int) {
        seletedIndies.append(index)
    }
    
    private func connect(point: CGPoint, to anotherPoint: CGPoint) {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        let line = (width: connectLineWidth, color: connectLineColor)
        
        connect(point: point, to: anotherPoint, in: context, with: line)
        _maskView.image = UIGraphicsGetImageFromCurrentImageContext()
        context.saveGState()
        UIGraphicsEndImageContext()
    }
    
    open func connect(point: CGPoint, to anotherPoint: CGPoint, `in` context: CGContext, with line:(width: CGFloat, color: UIColor)) {
        
    }
    
    func updateMaskView(with image: UIImage) {
        
    }
}
