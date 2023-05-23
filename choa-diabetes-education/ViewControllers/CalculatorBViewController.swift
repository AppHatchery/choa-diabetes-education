//
//  CalculatorBViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 1/3/23.
//

import UIKit
import Pendo

class CalculatorBViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var bloodSugarField: UITextField!
    @IBOutlet weak var targetBloodSugarField: UITextField!
    @IBOutlet weak var targetBloodSugarLine: UIView!
    @IBOutlet weak var targetBloodSugarLabel: UILabel!
    @IBOutlet weak var correctionFactorField: UITextField!
    @IBOutlet weak var correctionFactorLine: UIView!
    @IBOutlet weak var correctionFactorLabel: UILabel!
    @IBOutlet weak var bloodSugarAlert: UILabel!
    @IBOutlet weak var bloodSugarAlertIcon: UIImageView!
    @IBOutlet weak var bloodSugarLine: UIView!
    @IBOutlet weak var bloodSugarLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var textFieldCollection: [UITextField]!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var errorMessage: UILabel!
    
    var totalCarbs: Float = 0
    var bloodSugar: Float = 0
    var targetBloodSugar: Float = 0
    var carbRatio: Float = 0
    var correctionFactor: Float = 0
    
    var insulinForHighBloodSugarBoolean = false
    var insulinForFoodBoolean = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for txtField in textFieldCollection {
            txtField.delegate = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("should begin tediting")
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        print("text field ended editing")
        switch textField.tag {
        case 0:
            bloodSugar = Float(textField.text ?? "0") ?? 0
            print(bloodSugar)
            if bloodSugar < 150 && bloodSugar != 0 {
                bloodSugarAlertIcon.isHidden = false
                bloodSugarAlert.isHidden = false
                bloodSugarField.textColor = UIColor.orangeTextColor
            } else {
                bloodSugarAlertIcon.isHidden = true
                bloodSugarAlert.isHidden = true
                bloodSugarField.textColor = UIColor.choaGreenColor
            }
            toggleError(state: false, errorLine: bloodSugarLine, fieldLabel: bloodSugarLabel, errorMessageText: "")
        case 1:
            targetBloodSugar = Float(textField.text ?? "0") ?? 0
            print(targetBloodSugar)
            toggleError(state: false, errorLine: targetBloodSugarLine, fieldLabel: targetBloodSugarLabel, errorMessageText: "")
        case 2:
            correctionFactor = Float(textField.text ?? "0") ?? 0
            print(correctionFactor)
            toggleError(state: false, errorLine: correctionFactorLine, fieldLabel: correctionFactorLabel, errorMessageText: "")
        default:
            print("none of these")
        }
        
        errorMessage.isHidden = true
        //        if (bloodSugar != 0 && targetBloodSugar != 0 && correctionFactor != 0) {
        //            nextButton.isEnabled = true
        //        } else {
        //            nextButton.isEnabled = false
        //        }
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
    
    @IBAction func nextButton(_ sender: UIButton){
        self.view.endEditing(true)
        if (bloodSugar != 0 && targetBloodSugar != 0 && correctionFactor != 0){
            PendoManager.shared().track("Calculate_insulin_for_hbs", properties: ["blood_sugar":bloodSugar,"target_blood_sugar":targetBloodSugar,"correction_factor":correctionFactor])
            // Go to next page
            performSegue(withIdentifier: "SegueToCalculatorCViewController", sender: nil)
        }
        else if (bloodSugar != 0 && targetBloodSugar != 0 ) {
            // CarbRatio is not there
            toggleError(state: true, errorLine: correctionFactorLine, fieldLabel: correctionFactorLabel, errorMessageText: "Calculator.BloodSugar.CF.Error".localized())
        } else if (bloodSugar != 0 && correctionFactor != 0) {
            // Target BG is not there
            toggleError(state: true, errorLine: targetBloodSugarLine, fieldLabel: targetBloodSugarLabel, errorMessageText: "Calculator.BloodSugar.Target.Error".localized())
        } else if (targetBloodSugar != 0 && correctionFactor != 0) {
            // BG is not there
            toggleError(state: true, errorLine: bloodSugarLine, fieldLabel: bloodSugarLabel, errorMessageText: "Calculator.BloodSugar.Number.Error".localized())
            bloodSugarAlertIcon.isHidden = true
        } else {
            errorMessage.text = "Calculator.Carbs.MissingInfo.Error".localized()
            errorMessage.isHidden = false
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
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
        print("hide")
        view.frame.origin.y = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let calculatorCViewController = segue.destination as? CalculatorCViewController
        {
            calculatorCViewController.insulinForFoodBoolean = insulinForFoodBoolean
            calculatorCViewController.insulinForHighBloodSugarBoolean = insulinForHighBloodSugarBoolean
            
            calculatorCViewController.totalCarbs = totalCarbs
            calculatorCViewController.carbRatio = carbRatio
            calculatorCViewController.bloodSugar = bloodSugar
            calculatorCViewController.targetBloodSugar = targetBloodSugar
            calculatorCViewController.correctionFactor = correctionFactor
        }
    }
    
    @objc func dismissKeyboard() {
        // To hide the keyboard when the user clicks search
        self.view.endEditing(true)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
