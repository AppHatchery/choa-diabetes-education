//
//  CalculatorEditViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 25/09/2025.
//

import UIKit

protocol CalculatorEditDelegate: AnyObject {
    func calculatorDidUpdateConstants()
}

class CalculatorEditViewController: UIViewController {
    @IBOutlet weak var carbRatioField: UITextField!
    @IBOutlet weak var targetBloodSugarField: UITextField!
    @IBOutlet weak var correctionRatio: UITextField!
    
    @IBOutlet var editTextFields: [UITextField]!
    
    @IBOutlet weak var saveButton: PrimaryButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    let infoPopup = InfoPopUpViewController()
    
    private let constantsManager = CalculatorConstantsManager.shared
    
    weak var delegate: CalculatorEditDelegate?
    
    private var originalViewHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        
        appearance.backgroundColor = .whiteColor
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        

        // Do any additional setup after loading the view.
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        setupTrailingText()
        loadStoredConstants()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        originalViewHeight = view.frame.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadStoredConstants()
    }
    
    private func setupTrailingText() {
        setupTrailingText(for: carbRatioField, text: "g/unit")
        setupTrailingText(for: targetBloodSugarField, text: "mg/dL")
        setupTrailingText(for: correctionRatio, text: "")
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
        
        let textFieldPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.rightView = containerView
        textField.rightViewMode = .always
        
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.layer.masksToBounds = true
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .always
        containerView.layer.cornerRadius = 8
    }
        
    private func loadStoredConstants() {
        if constantsManager.hasStoredConstants {
            let constants = constantsManager.getConstants()
            
            carbRatioField.text = constants.carbRatio > 0 ? String(constants.carbRatio) : ""
            targetBloodSugarField.text = constants.targetBloodSugar > 0 ? String(constants.targetBloodSugar) : ""
            correctionRatio.text = constants.correctionFactor > 0 ? String(constants.correctionFactor) : ""
        }
    }
        
    private func updateSaveButtonState() {
        let carbRatio = Float(carbRatioField.text ?? "") ?? 0
        let targetBloodSugar = Float(targetBloodSugarField.text ?? "") ?? 0
        let correctionFactor = Float(correctionRatio.text ?? "") ?? 0
        
        let allFieldsValid = carbRatio > 0 && targetBloodSugar > 0 && correctionFactor > 0
        
        saveButton.isEnabled = allFieldsValid
        saveButton.alpha = allFieldsValid ? 1.0 : 0.5
    }
    
        // MARK: - UITextFieldDelegate
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow only numbers and decimal point
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let characterSet = CharacterSet(charactersIn: string)
        
        // Check if the new character is allowed
        guard allowedCharacters.isSuperset(of: characterSet) else {
            return false
        }
        
        // Prevent multiple decimal points
        if string == "." && textField.text?.contains(".") == true {
            return false
        }
        
        // Update save button state after text changes
        DispatchQueue.main.async {
            self.updateSaveButtonState()
        }
        
        return true
    }
        
    @IBAction func saveConstantsTap(_ sender: Any) {
        guard let carbRatioText = carbRatioField.text, !carbRatioText.isEmpty,
              let targetBloodSugarText = targetBloodSugarField.text, !targetBloodSugarText.isEmpty,
              let correctionFactorText = correctionRatio.text, !correctionFactorText.isEmpty else {
            
            // Show error alert
            showAlert(title: "Missing Information", message: "Please fill in all fields before saving.")
            return
        }
        
        let carbRatio = Int(carbRatioText) ?? 0
        let targetBloodSugar = Int(targetBloodSugarText) ?? 0
        let correctionFactor = Int(correctionFactorText) ?? 0
        
        guard carbRatio > 0 && targetBloodSugar > 0 && correctionFactor > 0 else {
            showAlert(title: "Invalid Values", message: "Please enter valid positive numbers for all fields.")
            return
        }
        
        // Save constants
        constantsManager.saveConstants(
            carbRatio: carbRatio,
            targetBloodSugar: targetBloodSugar,
            correctionFactor: correctionFactor
        )
        
        // Notify delegate before popping
        delegate?.calculatorDidUpdateConstants()
        
        // Show success message
        showAlert(title: "Success", message: "Constants saved successfully!") { _ in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showCarbRatioInfo(_ sender: Any) {
        infoPopup.appear(sender: self, title: "PopupInfo.CarbRatio.title".localized()
                         , details: "PopupInfo.CarbRatio.text".localized())
    }
    
    @IBAction func showTargetBloodSugarInfo(_ sender: Any) {
        infoPopup
            .appear(
                sender: self,
                title: "PopupInfo.TargetBloodSugar.title".localized()
                , details: "PopupInfo.TargetBloodSugar.text".localized())
    }
    
    @IBAction func showCorrectionFactorInfo(_ sender: Any) {
        infoPopup.appear(sender: self, title: "PopupInfo.CorrectionFactor.title".localized()
                         , details: "PopupInfo.CorrectionFactor.text".localized())
    }
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let window = view.window else { return }

        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let curve = UIView.AnimationOptions(rawValue: curveRaw << 16)

        // Convert keyboard frame to view's coordinate space
        let keyboardFrameInView = view.convert(keyboardFrameEnd, from: window.screen.coordinateSpace)
        let intersection = view.bounds.intersection(keyboardFrameInView)
        let overlapHeight = intersection.height

        if originalViewHeight == 0 { originalViewHeight = view.frame.height }

        if overlapHeight > 0 {
            var newFrame = view.frame
            newFrame.size.height = max(originalViewHeight - overlapHeight, 0)
            UIView.animate(withDuration: duration, delay: 0, options: [curve, .beginFromCurrentState], animations: {
                self.view.frame = newFrame
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            if originalViewHeight > 0 {
                var restored = view.frame
                restored.size.height = originalViewHeight
                view.frame = restored
            }
            return
        }
        
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let curve = UIView.AnimationOptions(rawValue: curveRaw << 16)

        if originalViewHeight > 0 {
            var restored = view.frame
            restored.size.height = originalViewHeight
            UIView.animate(withDuration: duration, delay: 0, options: [curve, .beginFromCurrentState], animations: {
                self.view.frame = restored
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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

