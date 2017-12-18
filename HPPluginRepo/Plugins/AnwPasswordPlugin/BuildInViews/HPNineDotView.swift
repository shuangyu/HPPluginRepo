//
//  HPNineDotView.swift
//  HPPluginRepo
//
//  Created by Hu, Peng on 15/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

let kNDVMainColor = UIColor.color255(from: (r: 91.0, g: 153.0, b: 238.0, a: 1.0))
let kNDVSelectedBorderColor = UIColor.color255(from: (r: 53.0, g: 183.0, b: 127.0, a: 1.0))
let kNDVErrorLineColor = UIColor.color255(from: (r: 53.0, g: 183.0, b: 127.0, a: 1.0))

class HPNineDotViewStorage: NSObject, IHPPasswordStorage {
    
    static let passwordKey = "com.hpDemo.9DotView.password.key"
    let defaultStorage = UserDefaults.standard
    var _password: String?
    var password: String? {
        if _password == nil {
            _password = defaultStorage.string(forKey: HPNineDotViewStorage.passwordKey)
        }
        return _password
    }
    
    func save(password: String) {
        defaultStorage.set(password, forKey: HPNineDotViewStorage.passwordKey)
    }
    
    func deletePassword() {
        defaultStorage.removeObject(forKey: HPNineDotViewStorage.passwordKey)
    }
    
    func validate(password: Any?) -> Bool {
        
        guard let indies = password as? Array<Int> else {
            return false
        }
        return indies.count >= 3
    }
    
    func password(from: Any?) -> String? {
        guard let indies = from as? Array<Int> else {
            return nil
        }
        
        return indies.map({ (i) -> String in
            return "\(i)"
        }) .joined(separator: "-")
    }
}

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
    
    
    @IBOutlet weak var draggedLineMaskView: UIImageView!
    @IBOutlet weak var connectedLineMaskView: UIImageView!
    private var nineDotImage: UIImage?
    private var seletedIndies: Array<Int> = []
    
    // Logic Var.
    private var dotRects: Array<CGRect> = []
    private var prePoint: CGPoint?
    private var preIndex: Int = NSNotFound
    lazy private var currentStatus: HPPasswordViewStatus = self.status
    lazy private var leftTryTime = self.maxTryTime
    
    // MARK: - IHPPasswordView implementation
    var maxTryTime: Int {
        return 3
    }
    
    var status: HPPasswordViewStatus = .create
    
    var tmpPassword: Any? {
        get {
            return seletedIndies
        }
        set(newValue) {
            seletedIndies = newValue as! Array<Int>
        }
        
    }
    
    var delegate: HPPasswordViewDelegate?
    
    //
    
    private var _decorator: HPPasswordViewDecorator<HPNineDotView, HPNineDotViewStorage>? = nil
    
    private var decorator: HPPasswordViewDecorator<HPNineDotView, HPNineDotViewStorage> {
        if _decorator == nil {
            _decorator = HPPasswordViewDecorator(passwordView: self, storage: HPNineDotViewStorage())
        }
        return _decorator!
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.delegate?.beginInput(passwordView: self)
        
        let touch = touches.first!
        let point = touch.location(in: self)
        
        let index = selectedDot(with: point)

        guard index != NSNotFound else {
            return
        }
        didSelectDot(at: index)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard preIndex != NSNotFound else {
            return
        }
        
        let touch = touches.first!
        let point = touch.location(in: self)
        
        connect(point: prePoint!, to: point)
        
        let index = selectedDot(with: point)
        
        guard index != NSNotFound  && index != preIndex else {
            return
        }
        
        let middleIndex = middleDot(between: preIndex, and: index)
        
        if middleIndex != NSNotFound {
            connectDot(at: preIndex, toIndex: middleIndex)
            didSelectDot(at: middleIndex)
        }
        
        connectDot(at: preIndex, toIndex: index)
        didSelectDot(at: index)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard preIndex != NSNotFound else {
            return
        }
        
        decorator.triggerStatusChange(HPPasswordViewStatusChange(from: self.currentStatus, to: .empty, tryTimes: leftTryTime))
        draggedLineMaskView.image = nil
        
        self.delegate?.endInput(passwordView: self)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    override open func draw(_ rect: CGRect) {
        
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()!
        for i in 0..<9 {
            let center = centerOfDot(at: i)
            draw(dot: (radius: CGFloat(dotRadius), center: center), with: context)
            dotRects.append(CGRect.rectOfCircle(center: center, radius: dotRadius))
            
        }
        nineDotImage = UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    private func resetView() {
        connectedLineMaskView.image = nil
        draggedLineMaskView.image = nil
        seletedIndies.removeAll()
        preIndex = NSNotFound
        prePoint = nil
    }
    
    // MARK: - IHPPasswordView implementation
    
    open func passwordImage() -> UIImage? {
        return nil
    }
    
    func updateView(with change: HPPasswordViewStatusChange) {
        
        let toStatus = change.to
        if toStatus != .mismatch || toStatus != .invalid {
            resetView()
        } else {
            
        }
    }
    
    // MARK: -
    
    private func centerOfDot(at index: Int) -> CGPoint {
        let w = self.bounds.width
        let h = self.bounds.height
        
        let viewCenter = CGPoint(x: w/2.0, y: h/2.0)
        let viewCenterRow = 1
        let viewCenterColumn = 1
        
        let row = index/3
        let column = index%3
        
        let x = viewCenter.x + CGFloat(column - viewCenterRow) * (dotRadius * 2 + dotMargin)
        let y = viewCenter.y + CGFloat(row - viewCenterColumn) * (dotRadius * 2 + dotMargin)
        return CGPoint(x: x, y: y)
    }
    
    open func draw(dot: (radius: CGFloat, center: CGPoint), with context: CGContext) {
        context.addArc(center: dot.center, radius: dot.radius, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: false)
        context.setStrokeColor(dotBorderColor.cgColor)
        context.setLineWidth(dotBordrrWidth)
        context.strokePath()
    }
    

    private func selectedDot(with touchPoint:CGPoint) -> Int {
        
        var matchedIndex = NSNotFound
        
        for dotRect in dotRects {
            if dotRect.contains(touchPoint) {
                matchedIndex = dotRects.index(of: dotRect)!
                break
            }
        }
        
        // case: no matched dot has been found
        guard matchedIndex != NSNotFound else {
            return NSNotFound
        }
        
        // case: first dot always can be selected
        guard preIndex != NSNotFound else {
            return matchedIndex
        }
        
        // case: duplicated seleted index
        guard !seletedIndies.contains(matchedIndex) else {
            return NSNotFound
        }
        
        // case: some special connect logic has not been fulfilled
        guard canConnectPoint(at: preIndex, to: matchedIndex) else {
            return NSNotFound
        }
        
        return matchedIndex
    }
    
    private func middleDot(between oneDot: Int, and anotherDot: Int) -> Int {
        
        guard (oneDot + anotherDot)%2 == 0 else {
            return NSNotFound
        }
        
        let middleIndex = (oneDot + anotherDot)/2
        
        guard !seletedIndies.contains(middleIndex) else {
            return NSNotFound
        }
        
        let fromPoint = dotRects[oneDot].center
        let toPoint = dotRects[anotherDot].center
        let middlePoint = dotRects[middleIndex].center
        
        guard middlePoint.slope(with: fromPoint) == middlePoint.slope(with: toPoint) else {
            return NSNotFound
        }
        return middleIndex
    }
    
    /*
     * override this function if there are some special demands
     * ex. only nearby point can be connected to each other...
     */
    open func canConnectPoint(at index: Int, to point: Int) -> Bool {
        return true
    }
    
    private func didSelectDot(at index: Int) {
        seletedIndies.append(index)
        preIndex = index
        prePoint = dotRects[index].center
    }
    
    private func connectDot(at index: Int, toIndex: Int ) {
        
        let fromPoint = dotRects[index].center
        let toPoint = dotRects[toIndex].center
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        connectedLineMaskView.image?.draw(in: self.bounds)
        context.saveGState()
        
        let line = (width: connectLineWidth, color: connectLineColor)
        connect(point: fromPoint, to: toPoint, in: context, with: line)
        
        connectedLineMaskView.image = UIGraphicsGetImageFromCurrentImageContext()
        context.saveGState()
        UIGraphicsEndImageContext()
        
    }
    
    open func connect(point: CGPoint, to anotherPoint: CGPoint) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        let line = (width: connectLineWidth, color: connectLineColor)
        connect(point: point, to: anotherPoint, in: context, with: line)
        draggedLineMaskView.image = UIGraphicsGetImageFromCurrentImageContext()
        context.saveGState()
        UIGraphicsEndImageContext()
    }
    
    open func connect(point: CGPoint, to anotherPoint: CGPoint, `in` context: CGContext, with line:(width: CGFloat, color: UIColor)) {
        
        let lineColor = line.color
        let lineWidth = line.width
        
        context.setLineCap(.round)
        context.move(to: point)
        context.addLine(to: anotherPoint)
        context.setLineWidth(lineWidth)
        context.setStrokeColor(lineColor.cgColor)
        context.strokePath()
        context.saveGState()
    }
}
