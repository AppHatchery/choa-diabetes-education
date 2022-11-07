//
//  CalculatorViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 8/4/22.
//

import UIKit

class CalculatorViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var resultsView: UIView!
    @IBOutlet var textFieldCollection: [UITextField]!
    @IBOutlet weak var totalCarbsField: UITextField!
    @IBOutlet weak var bloodSugarField: UITextField!
    @IBOutlet weak var targetBloodSugarField: UITextField!
    @IBOutlet weak var carbRatioButton: UIButton!
    @IBOutlet weak var correctionFactorButton: UIButton!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var insulinForFood: UILabel!
    @IBOutlet weak var insulinForBloodSugar: UILabel!
    @IBOutlet weak var totalInsulin: UILabel!
    
//    var insulinForFood = 0
//    var insulinForBloodSugar = 0
    var totalCarbs: Int = 0
    var bloodSugar: Int = 0
    var targetBloodSugar: Int = 0
    var carbRatio: Int = 15
    var correctionFactor: Int = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsView.layer.cornerRadius = 30
        
        // Keyboard dismiss state
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        customView.backgroundColor = UIColor( red: 0xd5/255.0, green: 0xd8/255.0, blue: 0xdc/255.0, alpha: 1)
        let doneButton = UIButton( frame: CGRect( x: view.frame.width - 70 - 10, y: 0, width: 70, height: 44 ))
        doneButton.setTitle( "Close", for: .normal )
        doneButton.setTitleColor( UIColor.systemBlue, for: .normal)
        doneButton.addTarget( self, action: #selector( self.dismissKeyboard), for: .touchUpInside )
        customView.addSubview( doneButton )
        
        for txtField in textFieldCollection {
            txtField.inputAccessoryView = customView
            txtField.delegate = self
            txtField.layer.cornerRadius = 15
        }
        
        
        let carbAction = { (action: UIAction) in
            //
            self.carbRatio = Int(action.title) ?? 0
        }
        
        carbRatioButton.menu = UIMenu(children:[
            UIAction(title: "5",handler: carbAction),
            UIAction(title: "10",handler: carbAction),
            UIAction(title: "15", state: .on, handler: carbAction),
            UIAction(title: "20",handler: carbAction),
        ])
        
        carbRatioButton.showsMenuAsPrimaryAction = true
        carbRatioButton.changesSelectionAsPrimaryAction = true

        let correctionAction = { (action: UIAction) in
            //
            self.correctionFactor = Int(action.title) ?? 0
        }
        
        correctionFactorButton.menu = UIMenu(children:[
            UIAction(title: "1",handler: correctionAction),
            UIAction(title: "2", state: .on, handler: correctionAction),
            UIAction(title: "3",handler: correctionAction),
            UIAction(title: "4",handler: correctionAction),
        ])
        
        
        
        correctionFactorButton.showsMenuAsPrimaryAction = true
        correctionFactorButton.changesSelectionAsPrimaryAction = true
        // Do any additional setup after loading the view.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("should begin tediting")
        if textField.text == "-" {
            textField.text = ""
        } else {
            textField.text = ""
        }
    }
        
    func textFieldDidEndEditing(_ textField: UITextField) {

        print("text field ended editing")
        switch textField.tag {
        case 0:
            totalCarbs = Int(textField.text ?? "0") ?? 0
            print(totalCarbs)
        case 1:
            bloodSugar = Int(textField.text ?? "0") ?? 0
            print(bloodSugar)
        case 2:
            targetBloodSugar = Int(textField.text ?? "0") ?? 0
            print(targetBloodSugar)
        default:
            print("none of these")
        }
        
        if totalCarbs != 0 && bloodSugar != 0 && targetBloodSugar != 0 {
            calculateButton.isEnabled = true
        } else {
            calculateButton.isEnabled = false
        }
    }
    
    
    
    
    @IBAction func calculateInsulin(_ sender: UIButton) {
        // Algorithm operations to calculate each block
        
        // Insulin for food
        insulinForFood.text = String(totalCarbs / carbRatio)
        
        // Insulin for blood sugar
        insulinForBloodSugar.text = String((bloodSugar - targetBloodSugar) / correctionFactor)
        // Total insulin
        totalInsulin.text = String(totalCarbs / carbRatio + (bloodSugar - targetBloodSugar) / correctionFactor)
        print("calculate insulin")
        
        self.view.endEditing(true)
    }
    
    @objc func dismissKeyboard() {
        // To hide the keyboard when the user clicks search
        self.view.endEditing(true)
    }
}