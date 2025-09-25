//
//  CalculatorEditViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 25/09/2025.
//

import UIKit

class CalculatorEditViewController: UIViewController {
    @IBOutlet weak var carbRatioField: UITextField!
    @IBOutlet weak var targetBloodSugarField: UITextField!
    @IBOutlet weak var correctionRatio: UITextField!
    
    @IBOutlet var editTextFields: [UITextField]!
    
    @IBOutlet weak var saveButton: PrimaryButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        
        appearance.backgroundColor = .whiteColor
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        

        // Do any additional setup after loading the view.
        setupTrailingText()
    }
    
    private func setupTrailingText() {
        setupTrailingText(for: carbRatioField, text: "g/unit")
        setupTrailingText(for: targetBloodSugarField, text: "mg/dL")
        
        editTextFields.forEach {
            $0.layer.cornerRadius = 8
        }
    }

    private func setupTrailingText(for textField: UITextField, text: String) {
        let trailingLabel = UILabel()
        trailingLabel.text = text
        trailingLabel.textColor = .black
        trailingLabel.font = textField.font
        trailingLabel.sizeToFit()
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: trailingLabel.frame.width + 12, height: trailingLabel.frame.height))
        containerView.addSubview(trailingLabel)
        
        trailingLabel.center = containerView.center
        
        textField.borderStyle = .roundedRect
        textField.rightView = containerView
        textField.rightViewMode = .always
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func saveConstantsTap(_ sender: Any) {
    }
    
    @IBAction func cancelTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
