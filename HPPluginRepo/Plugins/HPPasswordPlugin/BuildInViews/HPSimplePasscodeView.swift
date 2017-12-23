//
//  HPSimplePasscodeView.swift
//  HPPluginRepo
//
//  Created by Hu, Peng on 22/12/2017.
//  Copyright © 2017 Hu, Peng. All rights reserved.
//

import UIKit

class HPPasscodeInputViewCursor: UIView {
    
    private var _show = false
    var show: Bool {
        set(newValue) {
            _show = newValue
            if newValue {
                timer.fire()
            } else {
                timer.invalidate()
                self.isHidden = true
            }
        }
        get {
           
            return _show
        }
    }
    var _timer: Timer?
    
    var timer: Timer {
        if _timer == nil || !_timer!.isValid {
            _timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { (t) in
                self.isHidden = !self.isHidden
            }
        }
        return _timer!
    }
}

@IBDesignable class HPPasscodeInputView: UIView {
    
    enum BorderMask: Int {
        case none = 0
        case top = 1
        case right = 2
        case bottom = 4
        case left = 8
        case all = 15
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.color255(from: (r: 12.0, g: 81.0, b: 149, a: 1.0))
    @IBInspectable var errorColor: UIColor = UIColor.color255(from: (r: 255.0, g: 78.0, b: 78.0, a: 1.0))
    @IBInspectable var borderWidth: CGFloat = 1
    @IBInspectable var borderMask: Int = BorderMask.all.rawValue
    
    @IBOutlet weak var cursor: HPPasscodeInputViewCursor!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var _selected: Bool = false;
    private var _text: String?
    
    var showError: Bool = false
    
    var selected: Bool {
        get {
            return _selected
        }
        set(newValue) {
            cursor.show = newValue
            _selected = newValue
        }
    }
    
    var text: String? {
        get {
            return _text
        }
        set(newValue) {
            
            _text = newValue
            titleLabel.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selected = false
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let w = rect.width
        let h = rect.height
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(showError ? errorColor.cgColor : borderColor.cgColor)
        context.setLineWidth(borderWidth)
        if borderMask | BorderMask.top.rawValue > 0 {
            context.move(to: CGPoint.zero)
            context.addLine(to: CGPoint(x: w, y: 0))
            context.strokePath()
            context.saveGState()
        }

        if borderMask | BorderMask.right.rawValue > 0 {
            context.move(to: CGPoint(x: w, y: 0))
            context.addLine(to: CGPoint(x: w, y: h))
            context.strokePath()
            context.saveGState()
        }

        if borderMask | BorderMask.bottom.rawValue > 0 {
            context.move(to: CGPoint(x: w, y: h))
            context.addLine(to: CGPoint(x: 0, y: h))
            context.strokePath()
            context.saveGState()
        }

        if borderMask | BorderMask.left.rawValue > 0 {
            context.move(to: CGPoint(x: 0, y: h))
            context.addLine(to: CGPoint(x: 0, y: 0))
            context.strokePath()
            context.saveGState()
        }
    }
}

class HPSimplePasscodeViewStorage: NSObject, IHPPasswordStorage {
    
    static let passwordKey = "com.hpDemo.simplePasswordView.key"
    
    let defaultStorage = UserDefaults.standard
    var _password: String?
    var password: String? {
        if _password == nil {
            _password = defaultStorage.string(forKey: HPSimplePasscodeViewStorage.passwordKey)
        }
        return _password
    }
    
    func save(password: String) {
        defaultStorage.set(password, forKey: HPSimplePasscodeViewStorage.passwordKey)
    }
    
    func deletePassword() {
        defaultStorage.removeObject(forKey: HPSimplePasscodeViewStorage.passwordKey)
    }
    func validate(password: Any?) -> Bool {
        return true
    }
    
    func password(from: Any?) -> String? {
        guard let passcodeArr = from as? Array<String> else {
            return nil
        }
        return passcodeArr.joined(separator: "-")
    }
}

@IBDesignable class HPSimplePasscodeView: UIView, IHPPasswordView, UITextFieldDelegate {
    
    @IBOutlet var inputViews: [HPPasscodeInputView]!
    @IBOutlet weak var textField: UITextField!
    private var enable: Bool = true
    
    var tmpPassword: Any? {
        get {
            return [inputViews[0].text, inputViews[1].text, inputViews[2].text, inputViews[3].text]
        }
        set(newValue) {
            guard let textArr = newValue as? Array<String> else {
                return
            }
            inputViews[0].text = textArr[0]
            inputViews[1].text = textArr[1]
            inputViews[2].text = textArr[2]
            inputViews[3].text = textArr[3]
        }
        
    }
    var maxTryTime: Int {
        return 3
    }
    var status: HPPasswordViewStatus = .create
    
    var delegate: HPPasswordViewDelegate?
    
    private var _decorator: HPPasswordViewDecorator<HPSimplePasscodeView, HPSimplePasscodeViewStorage>? = nil
    
    private var decorator: HPPasswordViewDecorator<HPSimplePasscodeView, HPSimplePasscodeViewStorage> {
        if _decorator == nil {
            _decorator = HPPasswordViewDecorator(passwordView: self, storage: HPSimplePasscodeViewStorage())
        }
        return _decorator!
    }
    
    private var currentIndex = 0
    lazy private var leftTryTime = self.maxTryTime
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        textField.becomeFirstResponder()
        inputViews.first!.selected = true
    }
    
    @objc private func resetView() {
       
        for inputView in inputViews {
            inputView.text = nil
            inputView.selected = false
            inputView.showError = false
            inputView.setNeedsDisplay()
        }
        currentIndex = 0
        enable = true
        inputViews[currentIndex].selected = true
    }
    
    private func showErrorStatus() {
        
        
        inputViews[currentIndex].selected = false
        for inputView in inputViews {
            inputView.showError = true
            inputView.setNeedsDisplay()
        }
    }
    
    // MARK: - IHPPasswordView
    func passwordImage() -> UIImage? {
        return nil
    }
    
    func updateView(with change: HPPasswordViewStatusChange) {
        let toStatus = change.to
        leftTryTime = change.tryTimes
        enable = false
        if toStatus != .mismatch && toStatus != .invalid {
            perform(#selector(resetView), with: nil, afterDelay: 0.5)
        } else {
            showErrorStatus()
            perform(#selector(resetView), with: nil, afterDelay: 1)
        }
    }

    // MARK: - IHPPasswordView
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if !enable {
            return false
        }
        
        inputViews[currentIndex].text = string
        inputViews[currentIndex].selected = false
        currentIndex = (currentIndex + 1)%inputViews.count
        inputViews[currentIndex].selected = true
        
        if currentIndex == 0 {
            decorator.triggerStatusChange(HPPasswordViewStatusChange(from: self.status, to: .empty, tryTimes: self.leftTryTime))
        }
        
        return false
    }
}
