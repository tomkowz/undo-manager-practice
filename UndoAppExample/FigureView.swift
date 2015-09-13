//
//  FigureView.swift
//  UndoAppExample
//
//  Created by Tomasz Szulc on 12/09/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class FigureView: UIView {
    
    var changesRecorder = ChangesRecorder()
    private let privateUndoManager = NSUndoManager()    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.privateUndoManager.groupsByEvent = false
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        let defaultColor = UIColor(white: 0.7, alpha: 1)
        backgroundColor = defaultColor
        layer.borderColor = defaultColor.CGColor
        layer.borderWidth = 1.0
    }
    
    override var undoManager: NSUndoManager {
        return privateUndoManager
    }
    
    var cornerRadius: NSNumber {
        set {
            self.layer.cornerRadius = CGFloat(newValue.floatValue)
        }

        get { return NSNumber(float: Float(self.layer.cornerRadius)) }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
}
