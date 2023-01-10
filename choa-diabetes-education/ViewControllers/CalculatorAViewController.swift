//
//  CalculatorAViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 1/3/23.
//

import UIKit

class CalculatorAViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var totalCarbsField: UITextField!
    @IBOutlet weak var carbRatioField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var textFieldCollection: [UITextField]!
    @IBOutlet weak var contentView: UIView!
    
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
        case 1:
            carbRatio = Float(textField.text ?? "0") ?? 0
            print(carbRatio)
        default:
            print("none of these")
        }
        
        toggleNextButton()
    }
    
    func toggleNextButton(){
        if (totalCarbs > 0 && carbRatio > 0) {
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
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
        if insulinForHighBloodSugarBoolean {
            performSegue(withIdentifier: "SegueToCalculatorBViewController", sender: nil)
        } else {
            performSegue(withIdentifier: "SegueToCalculatorCViewController", sender: nil)
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
