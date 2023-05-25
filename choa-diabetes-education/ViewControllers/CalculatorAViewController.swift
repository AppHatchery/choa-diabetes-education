//
//  CalculatorAViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 1/3/23.
//

import UIKit
import Pendo

class CalculatorAViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var totalCarbsField: UITextField!
    @IBOutlet weak var carbLine: UIView!
    @IBOutlet weak var carbLabel: UILabel!
    @IBOutlet weak var carbRatioField: UITextField!
    @IBOutlet weak var carbRatioLine: UIView!
    @IBOutlet weak var carbRatioLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var textFieldCollection: [UITextField]!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var errorMessage: UILabel!
    
    var totalCarbs: Float = 0
    var carbRatio: Float = 0
    var insulinForHighBloodSugarBoolean = false
    var insulinForFoodBoolean = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for txtField in textFieldCollection {
            txtField.delegate = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("should begin tediting")
        textField.text = ""
    }
    
    
    // Yago to add
    // The next button should not require the user to dismiss the keyboard, rather it should change by itself once the field is no longer empty. Alternatively test if tapping on the screen to dismiss the keyboard works like in the search feature, and make this end editing
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField.tag {
        case 0:
            totalCarbs = Float(textField.text ?? "0") ?? 0
            print(totalCarbs)
            toggleError(state: false, errorLine: carbLine, fieldLabel: carbLabel, errorMessageText: "")
            carbLine.tintColor = UIColor.errorRedColor
        case 1:
            carbRatio = Float(textField.text ?? "0") ?? 0
            print(carbRatio)
            toggleError(state: false, errorLine: carbRatioLine, fieldLabel: carbRatioLabel, errorMessageText: "")
        default:
            print("none of these")
        }
        
        errorMessage.isHidden = true
        //        toggleNextButton()
    }
    
    func toggleError(state:Bool,errorLine: UIView, fieldLabel: UILabel, errorMessageText: String){
        if state {
            errorLine.backgroundColor = UIColor.red
            errorMessage.text = errorMessageText
            fieldLabel.textColor = UIColor.red
            errorMessage.isHidden = false
        } else {
            errorLine.backgroundColor = UIColor.errorRedColor
            errorMessage.text = errorMessageText
            fieldLabel.textColor = UIColor.contentBlackColor
            errorMessage.isHidden = true
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        //        print("in Show")
        guard let userInfo = notification.userInfo else { return }
        
        
        // In iOS 16.1 and later, the keyboard notification object is the screen the keyboard appears on.
        guard let screen = notification.object as? UIScreen,
              // Get the keyboard’s frame at the end of its animation.
              let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        
        // Use that screen to get the coordinate space to convert from.
        let fromCoordinateSpace = screen.coordinateSpace
        
        
        // Get your view's coordinate space.
        let toCoordinateSpace: UICoordinateSpace = view
        
        
        // Convert the keyboard's frame from the screen's coordinate space to your view's coordinate space.
        let convertedKeyboardFrameEnd = fromCoordinateSpace.convert(keyboardFrameEnd, to: toCoordinateSpace)
        
        // Get the safe area insets when the keyboard is offscreen.
        var bottomOffset = view.safeAreaInsets.bottom
        
        // Get the intersection between the keyboard's frame and the view's bounds to work with the
        // part of the keyboard that overlaps your view.
        let viewIntersection = view.bounds.intersection(convertedKeyboardFrameEnd)
        
        // Check whether the keyboard intersects your view before adjusting your offset.
        if !viewIntersection.isEmpty {
            
            // Adjust the offset by the difference between the view's height and the height of the
            // intersection rectangle.
            bottomOffset = view.bounds.maxY - viewIntersection.minY
        }
        
        
        // The jitter before was caused by having a contentView inside the main view that was moving instead of the view itself 022423
        // Use the new offset to adjust your UI, for example by changing a layout guide, offsetting
        // your view, changing a scroll inset, and so on. This example uses the new offset to update
        // the value of an existing Auto Layout constraint on the view.
        if view.frame.origin.y == 0 {
            view.frame.origin.y -= bottomOffset
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        view.frame.origin.y = 0
    }
    
    
    @objc func dismissKeyboard() {
        // To hide the keyboard when the user clicks search
        self.view.endEditing(true)
    }
    
    @IBAction func nextButton(_ sender: UIButton){
        self.view.endEditing(true)
        if (totalCarbs > 0 && carbRatio > 0){
            PendoManager.shared().track("Calculate_insulin_for_food", properties: ["carbs":totalCarbs,"ratio":carbRatio])
            if insulinForHighBloodSugarBoolean {
                performSegue(withIdentifier: "SegueToCalculatorBViewController", sender: nil)
            } else {
                performSegue(withIdentifier: "SegueToCalculatorCViewController", sender: nil)
            }
        } else if (totalCarbs > 0){
            // CarbRatio is not there
            toggleError(state: true, errorLine: carbRatioLine, fieldLabel: carbRatioLabel, errorMessageText: "Calculator.Carbs.Ratio.Error".localized())
        } else if (carbRatio > 0){
            // Carbs are not there
            toggleError(state: true, errorLine: carbLine, fieldLabel: carbLabel, errorMessageText: "Calculator.Carbs.Number.Error".localized())
        } else {
            // Nothing is there
            errorMessage.text = "Calculator.Carbs.MissingInfo.Error".localized()
            errorMessage.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let calculatorBViewController = segue.destination as? CalculatorBViewController {
            calculatorBViewController.insulinForFoodBoolean = insulinForFoodBoolean
            calculatorBViewController.insulinForHighBloodSugarBoolean = insulinForHighBloodSugarBoolean
            calculatorBViewController.totalCarbs = totalCarbs
            calculatorBViewController.carbRatio = carbRatio
        }
        if let calculatorCViewController = segue.destination as? CalculatorCViewController {
            calculatorCViewController.insulinForFoodBoolean = insulinForFoodBoolean
            calculatorCViewController.insulinForHighBloodSugarBoolean = insulinForHighBloodSugarBoolean
            calculatorCViewController.totalCarbs = totalCarbs
            calculatorCViewController.carbRatio = carbRatio
        }
    }
}
