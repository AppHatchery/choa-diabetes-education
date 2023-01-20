//
//  CalculatorAViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 1/3/23.
//

import UIKit

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
    
    // Yago to add
    // The next button should not require the user to dismiss the keyboard, rather it should change by itself once the field is no longer empty. Alternatively test if tapping on the screen to dismiss the keyboard works like in the search feature, and make this end editing
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        print("text field ended editing")
        switch textField.tag {
        case 0:
            totalCarbs = Float(textField.text ?? "0") ?? 0
            print(totalCarbs)
            toggleError(state: false, errorLine: carbLine, fieldLabel: carbLabel, errorMessageText: "")
            carbLine.tintColor = UIColor.init(red: 244/255, green: 239/255, blue: 249/255, alpha: 1.0)
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
            errorLine.backgroundColor = UIColor.init(red: 244/255, green: 239/255, blue: 249/255, alpha: 1.0)
            errorMessage.text = errorMessageText
            fieldLabel.textColor = UIColor.contentBlackColor
            errorMessage.isHidden = true
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
        // Display search field for typing - If statement prevents double movement when click another text field. Keyboard notification show function can get called without the Hide in between
        if contentView.frame.origin.y == 0 {
            contentView.frame.origin.y -= keyboardSize.height
        }        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
        print("hide")
        contentView.frame.origin.y = 0
    }
    
    @objc func dismissKeyboard() {
        // To hide the keyboard when the user clicks search
        self.view.endEditing(true)
    }
    
    @IBAction func nextButton(_ sender: UIButton){
        self.view.endEditing(true)
        if (totalCarbs > 0 && carbRatio > 0){
            if insulinForHighBloodSugarBoolean {
                performSegue(withIdentifier: "SegueToCalculatorBViewController", sender: nil)
            } else {
                performSegue(withIdentifier: "SegueToCalculatorCViewController", sender: nil)
            }
        } else if (totalCarbs > 0){
            // CarbRatio is not there
            toggleError(state: true, errorLine: carbRatioLine, fieldLabel: carbRatioLabel, errorMessageText: "Please enter a Carb Ratio")
        } else {
            // Carbs are not there
            toggleError(state: true, errorLine: carbLine, fieldLabel: carbLabel, errorMessageText: "Please enter the number of carbs")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let calculatorBViewController = segue.destination as? CalculatorBViewController
        {
            calculatorBViewController.insulinForFoodBoolean = insulinForFoodBoolean
            calculatorBViewController.insulinForHighBloodSugarBoolean = insulinForHighBloodSugarBoolean
            calculatorBViewController.totalCarbs = totalCarbs
            calculatorBViewController.carbRatio = carbRatio
        }
        if let calculatorCViewController = segue.destination as? CalculatorCViewController
        {
            calculatorCViewController.insulinForFoodBoolean = insulinForFoodBoolean
            calculatorCViewController.insulinForHighBloodSugarBoolean = insulinForHighBloodSugarBoolean
            calculatorCViewController.totalCarbs = totalCarbs
            calculatorCViewController.carbRatio = carbRatio
        }
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
