//
//  ViewController.swift
//  UndoAppExample
//
//  Created by Tomasz Szulc on 12/09/15.
//  Copyright © 2015 Tomasz Szulc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet private var undoButton: UIButton!
    @IBOutlet private var redoButton: UIButton!
    @IBOutlet private var boardView: BoardView!
    
    private var figures = [FigureView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeUndoManager()
        updateUndoAndRedoButtons()
    }
    
    @IBAction private func addRectangleTapped(sender: AnyObject) {
        let figureView = FigureView(frame: CGRectMake(view.center.x - 50, view.center.y - 50, 100, 100))
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: Selector("handleFigureLongPressGesture:"))
        longPressGesture.minimumPressDuration = 0.25
        figureView.addGestureRecognizer(longPressGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: Selector("handleDoubleTapGesture:"))
        doubleTapGesture.numberOfTapsRequired = 2
        figureView.addGestureRecognizer(doubleTapGesture)
        
        addFigure(figureView)
    }
    
    /// MARK: Actions on Figures
    func addFigure(figure: FigureView) {
        registerUndoAddFigure(figure)
        
        boardView.addSubview(figure)
        figures.append(figure)
        
        updateUndoAndRedoButtons()
    }
    
    func removeFigure(figure: FigureView) {
        registerUndoRemoveFigure(figure)
        
        figure.removeFromSuperview()
        if let index = figures.indexOf(figure) {
            figures.removeAtIndex(index)
        }
    }
    
    func moveFigure(figure: FigureView, center: CGPoint) {
        registerUndoMoveFigure(figure)
        figure.center = center
    }
    
    /// MARK: Undo Manager
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    private var _undoManager = NSUndoManager()
    override var undoManager: NSUndoManager {
        return _undoManager
    }
    
    private func observeUndoManager() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateUndoAndRedoButtons"), name: NSUndoManagerDidUndoChangeNotification, object: undoManager)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateUndoAndRedoButtons"), name: NSUndoManagerDidRedoChangeNotification, object: undoManager)
    }

    @objc private func updateUndoAndRedoButtons() {
        undoButton.enabled = undoManager.canUndo == true
        if undoManager.canUndo {
            undoButton.setTitle(undoManager.undoMenuTitleForUndoActionName(undoManager.undoActionName), forState: .Normal)
        } else {
            undoButton.setTitle(undoManager.undoMenuItemTitle, forState: .Normal)
        }
        
        redoButton.enabled = undoManager.canRedo == true
        if undoManager.canRedo {
            redoButton.setTitle(undoManager.redoMenuTitleForUndoActionName(undoManager.redoActionName), forState: .Normal)
        } else {
            redoButton.setTitle(undoManager.redoMenuItemTitle, forState: .Normal)
        }
    }
    
    /// MARK: Undo Manager Actions
    func registerUndoAddFigure(figure: FigureView) {
        undoManager.prepareWithInvocationTarget(self).removeFigure(figure)
        undoManager.setActionName("Add Figure")
    }
    
    func registerUndoRemoveFigure(figure: FigureView) {
        undoManager.prepareWithInvocationTarget(self).addFigure(figure)
        undoManager.setActionName("Remove Figure")
    }
    
    func registerUndoMoveFigure(figure: FigureView) {
        undoManager.prepareWithInvocationTarget(self).moveFigure(figure, center: figure.center)
        undoManager.setActionName("Move to \(figure.center)")
    }
    
    
    /// MARK: Gesture Recognizer
    func handleDoubleTapGesture(recognizer: UITapGestureRecognizer) {
        let figureView = recognizer.view as! FigureView
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let figureSettingsVC = storyboard.instantiateViewControllerWithIdentifier("FigureSettingsVC") as! FigureSettingsViewController
        figureSettingsVC.figure = figureView
        figureSettingsVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        
        let popoverPresentationController = figureSettingsVC.popoverPresentationController!
        popoverPresentationController.sourceView = figureView
        popoverPresentationController.sourceRect = CGRect(x: figureView.frame.width / 2.0, y: figureView.frame.height / 2.0, width: 0, height: 0)
        self.presentViewController(figureSettingsVC, animated: true, completion: nil)
    }
    
    func handleFigureLongPressGesture(recognizer: UILongPressGestureRecognizer) {
        let figure = recognizer.view as! FigureView
        switch recognizer.state {
        case .Began:
            registerUndoMoveFigure(figure)
            grabFigure(figure, gesture: recognizer)
        case .Changed:
            moveFigure(figure, gesture: recognizer)
        case .Ended:
            dropFigure(figure, gesture: recognizer)
            updateUndoAndRedoButtons()
        case .Cancelled:
            dropFigure(figure, gesture: recognizer)
        default:
            break
        }
    }
    
    private func grabFigure(figure: FigureView, gesture: UIGestureRecognizer) {
        UIView.animateWithDuration(0.2) {
            figure.transform = CGAffineTransformMakeScale(1.2, 1.2)
            figure.alpha = 0.8
        }
        
        moveFigure(figure, gesture: gesture)
    }
    
    private func moveFigure(figure: FigureView, gesture: UIGestureRecognizer) {
        figure.center = gesture.locationInView(self.view)
    }
    
    private func dropFigure(figure: FigureView, gesture: UIGestureRecognizer) {
        UIView.animateWithDuration(0.2) {
            figure.transform = CGAffineTransformIdentity
            figure.alpha = 1.0
        }
    }
}
