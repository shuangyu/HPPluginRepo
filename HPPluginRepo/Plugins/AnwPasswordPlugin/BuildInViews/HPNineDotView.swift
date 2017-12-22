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
let kNDVErrorLineColor = UIColor.color255(from: (r: 255.0, g: 78.0, b: 78.0, a: 1.0))

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
        
        guard let dots = password as? Array<HPNineDotView.Dot> else {
            return false
        }
        return dots.count >= 3
    }
    
    func password(from: Any?) -> String? {
        guard let dots = from as? Array<HPNineDotView.Dot> else {
            return nil
        }
        
        return dots.map({ (dot) -> String in
            return "\(dot.index)"
        }) .joined(separator: "-")
    }
}

@IBDesignable open class HPNineDotView: UIView, IHPPasswordView {

    public struct Dot {
        var center: CGPoint {
            return rect.center
        }
        var rect: CGRect
        var index: Int
        
        init(rect: CGRect, index: Int) {
            self.rect = rect
            self.index = index
        }
        
        func contains(_ point: CGPoint) -> Bool {
            return rect.contains(point)
        }
        
        static func == (lhs: Dot, rhs: Dot) -> Bool {
            return lhs.index == rhs.index
        }
        static func != (lhs: Dot, rhs: Dot) -> Bool {
            return lhs.index != rhs.index
        }
    }
    
    // UI Var.
    @IBInspectable var dotRadius: CGFloat = 30
    @IBInspectable var dotMargin: CGFloat = 30
    @IBInspectable var dotBorderWidth: CGFloat = 1
    @IBInspectable var dotBorderColor: UIColor = kNDVMainColor
    @IBInspectable var dotSelectedBorderColor: UIColor = kNDVSelectedBorderColor
    
    
    @IBInspectable var connectLineWidth: CGFloat = 2
    @IBInspectable var connectLineColor: UIColor = kNDVMainColor
    
    @IBInspectable var errorLineColor: UIColor = kNDVErrorLineColor
    
    @IBOutlet weak var draggedLineMaskView: UIImageView!
    @IBOutlet weak var connectedLineMaskView: UIImageView!
    
    
    private var effectViews: Array<UIView> = []
    private var selectedDots: Array<Dot> = []
    
    // Logic Var.
    private var dots: Array<Dot> = []
    private var preDot: Dot?
    lazy private var leftTryTime = self.maxTryTime
    
    // MARK: - IHPPasswordView implementation
    var maxTryTime: Int {
        return 3
    }
    
    var status: HPPasswordViewStatus = .create
    
    var tmpPassword: Any? {
        get {
            return selectedDots
        }
        set(newValue) {
            selectedDots = newValue as! Array<Dot>
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
        
        let dot = selectedDot(with: point)

        guard dot != nil else {
            return
        }
        didSelect(dot: dot!)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard preDot != nil else {
            return
        }
        
        let touch = touches.first!
        let point = touch.location(in: self)
        
        connect(point: preDot!.center, to: point)
        
        let dot = selectedDot(with: point)
        
        guard dot != nil else {
            return
        }
        
        guard dot! != preDot! else {
            return
        }
        
        let midDot = middleDot(between: preDot!, and: dot!)
        
        if midDot != nil {
            connect(preDot!, to: midDot!)
            didSelect(dot: midDot!)
        }
        
        connect(preDot!, to: dot!)
        didSelect(dot: dot!)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard preDot != nil else {
            return
        }
        
        decorator.triggerStatusChange(HPPasswordViewStatusChange(from: self.status, to: .empty, tryTimes: leftTryTime))
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
            let dot = Dot(rect:CGRect.rectOfCircle(center: center, radius: dotRadius), index: i)
            dots.append(dot)
        }
    }
    
    @objc
    private func resetView() {
        connectedLineMaskView.image = nil
        draggedLineMaskView.image = nil
        selectedDots.removeAll()
        preDot = nil
        for view in effectViews {
            view.removeFromSuperview()
        }
        effectViews.removeAll()
    }
    
    private func showErrorStatus() {
        
        var preDot = selectedDots.first!
        
        for dot in selectedDots {
            
            if dot != preDot {
                connect(preDot, to: dot, error: true)
                preDot = dot
            }
            applySelectedEffect(to: dot, error: true)
        }
        
    }
    
    // MARK: - IHPPasswordView implementation
    
    open func passwordImage() -> UIImage? {
        return nil
    }
    
    func updateView(with change: HPPasswordViewStatusChange) {
        
        let toStatus = change.to
        leftTryTime = change.tryTimes
        
        if toStatus != .mismatch && toStatus != .invalid {
            resetView()
        } else {
            showErrorStatus()
            perform(#selector(resetView), with: nil, afterDelay: 1)
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
        context.setLineWidth(dotBorderWidth)
        context.strokePath()
    }
    
    private func selectedDot(with touchPoint: CGPoint) -> Dot? {
        
        var matchedDot: Dot? = nil
        for dot in dots {
            if dot.contains(touchPoint) {
                matchedDot = dot
                break
            }
        }
        
        // case: no matched dot has been found
        guard matchedDot != nil else {
            return nil
        }
        
        // case: first dot always can be selected
        guard preDot != nil else {
            return matchedDot
        }
        
        // case: duplicated seleted index
        let duplicated = selectedDots.contains { (dot) -> Bool in
            return dot == matchedDot!
        }
        
        guard !duplicated else {
            return nil
        }
        
        // case: some special connect logic has not been fulfilled
        guard can(connect: preDot!, to: matchedDot!) else {
            return nil
        }
        
        return matchedDot
    }
    
    private func middleDot(between oneDot: Dot, and anotherDot: Dot) -> Dot? {
        
        guard (oneDot.index + anotherDot.index)%2 == 0 else {
            return nil
        }
        
        let middleIndex = (oneDot.index + anotherDot.index)/2
        let midDot = dots[middleIndex]
        
        let duplicated = selectedDots.contains { (dot) -> Bool in
            return dot == midDot
        }
        
        guard !duplicated else {
            return nil
        }
        
        let fromPoint = oneDot.center
        let toPoint = anotherDot.center
        let midPoint = midDot.center
        
        guard midPoint.slope(with: fromPoint) == midPoint.slope(with: toPoint) else {
            return nil
        }
        return midDot
    }
    
    /*
     * override this function if there are some special demands
     * ex. only nearby point can be connected to each other...
     */
    open func can(connect dot: Dot, to anotherDot: Dot) -> Bool {
        return true
    }
    
    private func didSelect(dot: Dot) {
        selectedDots.append(dot)
        preDot = dot
        applySelectedEffect(to: dot, error: false)
    }
    
    open func applySelectedEffect(to dot: Dot, error: Bool) {
        
        let effectView = UIView(frame: dot.rect.insetBy(dx: -dotBorderWidth, dy: -dotBorderWidth))
        effectView.backgroundColor = error ? errorLineColor : connectLineColor
        effectView.layer.cornerRadius = effectView.frame.width * 0.5
        effectView.layer.borderWidth = dotBorderWidth
        effectView.layer.borderColor = error ? errorLineColor.cgColor : connectLineColor.cgColor
        
        
        let animatedLayerSize: CGFloat = 20.0
        let scale = animatedLayerSize/dot.rect.width
        let animatedLayer = CALayer()
        animatedLayer.frame = effectView.bounds
        animatedLayer.cornerRadius = effectView.layer.cornerRadius
        animatedLayer.backgroundColor = UIColor.color255(from: (r: 245.0, g: 246.0, b: 247.0, a: 1.0)).cgColor
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
        animation.toValue = CATransform3DIdentity
        animation.duration = 0.2
        animation.isRemovedOnCompletion = false
        animatedLayer.add(animation, forKey: "scale")
        

        let centerLayer = CALayer()
        centerLayer.frame = CGRect.rect(with: effectView.bounds.center, size: CGSize(width: animatedLayerSize, height: animatedLayerSize))
        centerLayer.cornerRadius = animatedLayerSize * 0.5
        centerLayer.backgroundColor = error ? errorLineColor.cgColor : connectLineColor.cgColor
        
        effectView.layer.addSublayer(animatedLayer)
        effectView.layer.addSublayer(centerLayer)
    
        self.addSubview(effectView)
        effectViews.append(effectView)
    
    }
    
    private func connect(_ dot: Dot, to anotherDot: Dot, error: Bool = false) {
        
        let fromPoint = dot.center
        let toPoint = anotherDot.center
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        connectedLineMaskView.image?.draw(in: self.bounds)
        context.saveGState()
        
        let line = (width: connectLineWidth, color: error ? errorLineColor : connectLineColor)
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
