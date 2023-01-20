//
//  CalculatorBViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 1/3/23.
//

import UIKit

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

        // Keyboard dismiss state
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        customView.backgroundColor = UIColor( red: 0xd5/255.0, green: 0xd8/255.0, blue: 0xdc/255.0, alpha: 1)
        let doneButton = UIButton( frame: CGRect( x: view.frame.width - 70 - 10, y: 0, width: 70, height: 44 ))
        doneButton.setTitle( "Close", for: .normal )
        doneButton.setTitleColor( UIColor.systemBlue, for: .normal)
        doneButton.addTarget( self, action: #selector( self.dismissKeyboard), for: .touchUpInside )
        customView.addSubview( doneButton )
        // Do any additional setup after loading the view.
        
        
        for txtField in textFieldCollection {
            txtField.inputAccessoryView = customView
            txtField.delegate = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
            if bloodSugar < 150 {
                bloodSugarAlertIcon.isHidden = false
                bloodSugarAlert.isHidden = false
                bloodSugarField.textColor = UIColor.init(red: 250/255, green: 153/255, blue: 0, alpha: 1.0)
            } else {
                bloodSugarAlertIcon.isHidden = true
                bloodSugarAlert.isHidden = true
                bloodSugarField.textColor = UIColor.calculatorGreenColor
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
            errorLine.backgroundColor = UIColor.init(red: 244/255, green: 239/255, blue: 249/255, alpha: 1.0)
            errorMessage.text = errorMessageText
            fieldLabel.textColor = UIColor.contentBlackColor
            errorMessage.isHidden = true
        }
    }
    
    @IBAction func nextButton(_ sender: UIButton){
        self.view.endEditing(true)
        if (bloodSugar != 0 && targetBloodSugar != 0 && correctionFactor != 0){
            // Go to next page
            performSegue(withIdentifier: "SegueToCalculatorCViewController", sender: nil)
        }
        else if (bloodSugar != 0 && targetBloodSugar != 0 ){
            // CarbRatio is not there
            toggleError(state: true, errorLine: correctionFactorLine, fieldLabel: correctionFactorLabel, errorMessageText: "Please enter a Correction Factor")
        } else if (bloodSugar != 0 && correctionFactor != 0){
            // Target BG is not there
            toggleError(state: true, errorLine: targetBloodSugarLine, fieldLabel: targetBloodSugarLabel, errorMessageText: "Please enter your target blood sugar (it may be 100 during the day and 150 at night)")
        } else if (targetBloodSugar != 0 && correctionFactor != 0){
            // BG is not there
            toggleError(state: true, errorLine: bloodSugarLine, fieldLabel: bloodSugarLabel, errorMessageText: "Please enter your blood sugar")
        } else {
            errorMessage.text = "Please enter the missing information"
            errorMessage.isHidden = false
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        print("in Show")
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else {
            // if keyboard size is not available for some reason, dont do anything
                print("in else")
                
            return
        }
        
        if contentView.frame.origin.y == 0 {
            contentView.frame.origin.y -= keyboardSize.height
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
        print("hide")
        contentView.frame.origin.y = 0
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
