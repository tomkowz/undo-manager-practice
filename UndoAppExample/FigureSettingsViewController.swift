//
//  FigureSettingsViewController.swift
//  UndoAppExample
//
//  Created by Tomasz Szulc on 13/09/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

extension FigureView {
    
    func recordBeginChanges() {
        self.changesRecorder.setValueForKey("backgroundColor", value: self.backgroundColor)
        self.changesRecorder.setValueForKey("cornerRadius", value: self.cornerRadius)
    }
    
    func revertChanges() {
        self.backgroundColor = self.changesRecorder.valueForKey("backgroundColor") as? UIColor
        self.cornerRadius = self.changesRecorder.valueForKey("cornerRadius") as! NSNumber
    }
    
    @objc private func registerUndoChange() {
        let changes = changesRecorder.dictionary
        
        let beginBackgroundColor = changes["backgroundColor"] as! UIColor
        let beginCornerRadius = changes["cornerRadius"] as! NSNumber
        
        let colorModified = self.backgroundColor! != beginBackgroundColor
        let cornerRadiusModified = self.cornerRadius.floatValue != beginCornerRadius.floatValue
        
        undoManager.beginUndoGrouping()
        undoManager.prepareWithInvocationTarget(self).registerUndoChange()
        undoManager.registerUndoWithTarget(self, selector: Selector("registerUndoChange"), object: nil)
        undoManager.registerUndoWithTarget(self, selector: Selector("setBackgroundColor:"), object: beginBackgroundColor)
        undoManager.registerUndoWithTarget(self, selector: Selector("setCornerRadius:"), object: beginCornerRadius)
        
        if colorModified && cornerRadiusModified {
            undoManager.setActionName("Change Color and Radius")
        } else if colorModified {
            undoManager.setActionName("Change Color")
        } else if cornerRadiusModified {
            undoManager.setActionName("Change Radius")
        }
        
        undoManager.endUndoGrouping()
    }
}

class FigureSettingsViewController: UIViewController {
    
    @IBOutlet var colorButtons: [UIButton]!
    @IBOutlet var cornerRadiusSlider: UISlider!
    @IBOutlet var undoButton: UIButton!
    @IBOutlet var redoButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    
    var figure: FigureView!
    var lockUndo: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeUndoManager()
        updateUndoAndRedoButtons()
        setupUI()
        updateBeginChanges()
        
        figure.addObserver(self, forKeyPath: "cornerRadius", options: [.New, .Initial], context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "cornerRadius" {
            cornerRadiusSlider.value = (change![NSKeyValueChangeNewKey] as! NSNumber).floatValue
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        figure.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        revertChanges()
        figure.removeObserver(self, forKeyPath: "cornerRadius")
        figure.resignFirstResponder()
    }
    
    private func setupUI() {
        colorButtons[0].backgroundColor = UIColor.redColor()
        colorButtons[1].backgroundColor = UIColor.blueColor()
        colorButtons[2].backgroundColor = UIColor.purpleColor()
        colorButtons[3].backgroundColor = UIColor(white: 0.7, alpha: 1)
        
        cornerRadiusSlider.value = Float(figure.layer.cornerRadius)
    }
    
    private func updateBeginChanges() {
        figure.recordBeginChanges()
    }
    
    private func revertChanges() {
        figure.revertChanges()
    }
    
    private func updateButtons() {
        saveButton.enabled = true
        if lockUndo {
            self.undoButton.enabled = false
            self.redoButton.enabled = false
        }
    }
    
    @IBAction func savePressed(sender: AnyObject) {
        figure.registerUndoChange()
        updateBeginChanges()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func changeColor(sender: UIButton) {
        lockUndo = true
        figure.backgroundColor = sender.backgroundColor
        updateButtons()
    }
    
    @IBAction func cornerRadiusValueChanged(sender: UISlider) {
        lockUndo = true
        figure.layer.cornerRadius = CGFloat(sender.value)
        updateButtons()
    }
    
    /// MARK: Undo Manager
    private func observeUndoManager() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("undoManagerDidUndoNotification"), name: NSUndoManagerDidUndoChangeNotification, object: figure.undoManager)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("undoManagerDidRedoNotification"), name: NSUndoManagerDidRedoChangeNotification, object: figure.undoManager)
    }
    
    func undoManagerDidUndoNotification() {
        updateUndoAndRedoButtons()
        figure.recordBeginChanges()
    }
    
    func undoManagerDidRedoNotification() {
        updateUndoAndRedoButtons()
        figure.recordBeginChanges()
    }

    private func updateUndoAndRedoButtons() {
        undoButton.enabled = figure.undoManager.canUndo == true
        if figure.undoManager.canUndo {
            undoButton.setTitle(figure.undoManager.undoMenuTitleForUndoActionName(figure.undoManager.undoActionName), forState: .Normal)
        } else {
            undoButton.setTitle(figure.undoManager.undoMenuItemTitle, forState: .Normal)
        }
        
        redoButton.enabled = figure.undoManager.canRedo == true
        if figure.undoManager.canRedo {
            redoButton.setTitle(figure.undoManager.redoMenuTitleForUndoActionName(figure.undoManager.redoActionName), forState: .Normal)
        } else {
            redoButton.setTitle(figure.undoManager.redoMenuItemTitle, forState: .Normal)
        }
    }
}
