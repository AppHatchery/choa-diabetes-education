//
//  CalculatorBViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 1/3/23.
//

import UIKit
import Pendo

class CalculatorBViewController: UIViewController, UITextFieldDelegate, CalculatorEditDelegate {
    
    @IBOutlet weak var bloodSugarField: UITextField!
    @IBOutlet weak var targetBloodSugarField: UITextField!
    @IBOutlet weak var targetBloodSugarLine: UIView!
    @IBOutlet weak var targetBloodSugarLabel: UILabel!
    @IBOutlet weak var correctionFactorField: UITextField!
    @IBOutlet weak var correctionFactorLine: UIView!
    @IBOutlet weak var correctionFactorLabel: UILabel!
    @IBOutlet weak var bloodSugarLine: UIView!
    @IBOutlet weak var bloodSugarLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var textFieldCollection: [UITextField]!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var resultsView: UIView!
    @IBOutlet weak var insulinForHighBloodSugarTitleLabel: UILabel!
    @IBOutlet weak var insulinForHighBloodSugar: UILabel!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    
    let infoPopup = InfoPopUpViewController()
    
    var totalCarbs: Int = 0
    var bloodSugar: Int = 0
    var targetBloodSugar: Int = 0
    var carbRatio: Int = 0
    var correctionFactor: Int = 0
    
    var insulinForHighBloodSugarBoolean = false
    var insulinForFoodBoolean = false
    var highBloodSugarOnly = false
    
    private let constantsManager = CalculatorConstantsManager.shared
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(true)
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .diabetesBasicsColor050
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.backButtonDisplayMode = .minimal
        
        calculatorDidUpdateConstants()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calculatorDidUpdateConstants()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var config = UIButton.Configuration.plain()
        config.title = "Edit"
        config.image = UIImage(named: "edit_pencil")

        config.imagePlacement = .trailing
        config.imagePadding = 2

        // Remove default padding
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let button = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
            self?.editButtonTapped()
        })

        let editButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = editButton

        
        for txtField in textFieldCollection {
            txtField.delegate = self
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        bloodSugarLine.layer.cornerRadius = 3
        targetBloodSugarLine.layer.cornerRadius = 3
        correctionFactorLine.layer.cornerRadius = 3
                
        resultsView.isHidden = true
        
        if highBloodSugarOnly == false {
            step2Label.isHidden = false

            nextButton.titleLabel?.text = "Next"
            nextButton.setImage(UIImage(named: "leftArrow"), for: .normal)
            nextButton.backgroundColor = .choaGreenColor
            nextButton.tintColor = .choaGreenColor
            nextButton.layer.cornerRadius = 12
        } else {
            step2Label.isHidden = true

            nextButton
                .setTitleWithStyle(
                    "Exit",
                    font: .gothamRoundedMedium20,
                    color: .choaGreenColor
                )
            nextButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            nextButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .small), forImageIn: .normal)
            nextButton.backgroundColor = .clear
            nextButton.configuration?.baseForegroundColor = .choaGreenColor
            nextButton.tintColor = .choaGreenColor
            nextButton.layer.cornerRadius = 12
        }
        
        calculatorDidUpdateConstants()
        setupTappableInfoButtons()
    }
    
    @objc private func editButtonTapped() {
        performSegue(withIdentifier: "calculatorBToEditSegue", sender: nil)
    }
    
    private func loadStoredConstants() {
        if constantsManager.hasStoredConstants {
            let constants = constantsManager.getConstants()
            
            // NOTE: This updates the UI (text fields to be exact) with stored constants
            
            if constants.targetBloodSugar > 0 {
                targetBloodSugar = constants.targetBloodSugar
                targetBloodSugarField.text = String(constants.targetBloodSugar)
            }
            
            if constants.correctionFactor > 0 {
                correctionFactor = constants.correctionFactor
                correctionFactorField.text = String(constants.correctionFactor)
            }
            
            // Call calculateFoodInsulin if all required values are present
            if constants.carbRatio > 0 || constants.targetBloodSugar > 0 || constants.correctionFactor > 0 {
                calculateFoodInsulin()
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("should begin tediting")
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField.tag {
        case 0:
            bloodSugar = Int(textField.text ?? "0") ?? 0
            print(bloodSugar)
            if bloodSugar < constantsManager.targetBloodSugar && bloodSugar != 0 {
                bloodSugarField.textColor = UIColor.orangeTextColor
                insulinForHighBloodSugar.textColor = .orangeTextColor
                bloodSugarLine.backgroundColor = .orangeTextColor
                bloodSugarLabel.textColor = .orangeTextColor
            } else if bloodSugar < targetBloodSugar && bloodSugar != 0 {
                bloodSugarField.textColor = UIColor.orangeTextColor
                insulinForHighBloodSugar.textColor = .orangeTextColor
                bloodSugarLine.backgroundColor = .orangeTextColor
                bloodSugarLabel.textColor = .orangeTextColor
            } else {
                bloodSugarField.textColor = .primaryBlue
                insulinForHighBloodSugar.textColor = .primaryBlue
                bloodSugarLine.backgroundColor = .primaryBlue
                bloodSugarLabel.textColor = .primaryBlue
            }
//            toggleError(state: false, errorLine: bloodSugarLine, fieldLabel: bloodSugarLabel, errorMessageText: "")
        case 1:
            targetBloodSugar = Int(textField.text ?? "0") ?? 0
            print(targetBloodSugar)
//            targetBloodSugarLine.backgroundColor = .black
            targetBloodSugarLabel.textColor = .black
//            toggleError(state: false, errorLine: targetBloodSugarLine, fieldLabel: targetBloodSugarLabel, errorMessageText: "")
        case 2:
            correctionFactor = Int(textField.text ?? "0") ?? 0
            print(correctionFactor)
//            correctionFactorLine.backgroundColor = .black
            correctionFactorLabel.textColor = .black
//            toggleError(state: false, errorLine: correctionFactorLine, fieldLabel: correctionFactorLabel, errorMessageText: "")
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
            fieldLabel.textColor = .primaryBlue
            errorMessage.isHidden = true
        }
    }
    
    @IBAction func nextButton(_ sender: UIButton){
        self.view.endEditing(true)
        
        if highBloodSugarOnly == false {
            if (bloodSugar != 0 && targetBloodSugar != 0 && correctionFactor != 0){
                PendoManager.shared().track("Calculate_insulin_for_hbs", properties: ["blood_sugar":bloodSugar,"target_blood_sugar":targetBloodSugar,"correction_factor":correctionFactor])
                // Go to next page
                performSegue(withIdentifier: "SegueToCalculatorCViewController", sender: nil)
            } else if (bloodSugar != 0 && targetBloodSugar != 0 ) {
                // CarbRatio is not there
                toggleError(state: true, errorLine: correctionFactorLine, fieldLabel: correctionFactorLabel, errorMessageText: "Calculator.BloodSugar.CF.Error".localized())
            } else if (bloodSugar != 0 && correctionFactor != 0) {
                // Target BG is not there
                toggleError(state: true, errorLine: targetBloodSugarLine, fieldLabel: targetBloodSugarLabel, errorMessageText: "Calculator.BloodSugar.Target.Error".localized())
            } else if (targetBloodSugar != 0 && correctionFactor != 0) {
                // BG is not there
                toggleError(state: true, errorLine: bloodSugarLine, fieldLabel: bloodSugarLabel, errorMessageText: "Calculator.BloodSugar.Number.Error".localized())
            } else {
                errorMessage.text = "Calculator.Carbs.MissingInfo.Error".localized()
                errorMessage.isHidden = false
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func setupTappableInfoButtons() {
        let showTargetBloodSugarInfoTap = UITapGestureRecognizer(target: self, action: #selector(didTapShowTargetBloodSugarInfo))
        targetBloodSugarLabel.addGestureRecognizer(showTargetBloodSugarInfoTap)
        targetBloodSugarLabel.isUserInteractionEnabled = true
        
        let showCorrectionFactorInfoTap = UITapGestureRecognizer(target: self, action: #selector(didTapShowCorrectionFactorInfo))
        correctionFactorLabel.addGestureRecognizer(showCorrectionFactorInfoTap)
        correctionFactorLabel.isUserInteractionEnabled = true

        
        let showInsulinForHighBloodSugarInfoTap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapShowInsulinForHighBloodSugarInfo))
        insulinForHighBloodSugarTitleLabel.addGestureRecognizer(showInsulinForHighBloodSugarInfoTap)
        insulinForHighBloodSugarTitleLabel.isUserInteractionEnabled = true
    }
    
    @objc private func didTapShowTargetBloodSugarInfo() {
        showTargetBloodSugarInfo(self)
    }
    
    @objc private func didTapShowCorrectionFactorInfo() {
        showCorrectionFactorInfo(self)
    }
    
    @objc private func didTapShowInsulinForHighBloodSugarInfo() {
        showInsulinForHighBloodSugarInfo(self)
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
    
    @IBAction func showInsulinForHighBloodSugarInfo(_ sender: Any) {
        infoPopup.appear(sender: self, title: "PopupInfo.InsulinForHighBloodSugar.title".localized()
                         , details: "PopupInfo.InsulinForHighBloodSugar.text".localized())
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        
        // In iOS 16.1 and later, the keyboard notification object is the screen the keyboard appears on.
        guard let _ = notification.object as? UIScreen,
              // Get the keyboard’s frame at the end of its animation.
              let _ = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        
        // Use that screen to get the coordinate space to convert from.
//        let fromCoordinateSpace = screen.coordinateSpace
//        
//        
//        // Get your view's coordinate space.
//        let toCoordinateSpace: UICoordinateSpace = view
//        
//        
//        // Convert the keyboard's frame from the screen's coordinate space to your view's coordinate space.
//        let convertedKeyboardFrameEnd = fromCoordinateSpace.convert(keyboardFrameEnd, to: toCoordinateSpace)
//        
//        // Get the safe area insets when the keyboard is offscreen.
//        var bottomOffset = view.safeAreaInsets.bottom
//        
//        // Get the intersection between the keyboard's frame and the view's bounds to work with the
//        // part of the keyboard that overlaps your view.
//        let viewIntersection = view.bounds.intersection(convertedKeyboardFrameEnd)
//        
//        // Check whether the keyboard intersects your view before adjusting your offset.
//        if !viewIntersection.isEmpty {
//            
//            // Adjust the offset by the difference between the view's height and the height of the
//            // intersection rectangle.
//            bottomOffset = view.bounds.maxY - viewIntersection.minY
//        }
//        
//        
//        // The jitter before was caused by having a contentView inside the main view that was moving instead of the view itself 022423
//        // Use the new offset to adjust your UI, for example by changing a layout guide, offsetting
//        // your view, changing a scroll inset, and so on. This example uses the new offset to update
//        // the value of an existing Auto Layout constraint on the view.
//        if view.frame.origin.y == 0 {
//            view.frame.origin.y -= bottomOffset
//        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        view.frame.origin.y = 0
    }
    
    func calculatorDidUpdateConstants() {
        loadStoredConstants()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let calculatorCViewController = segue.destination as? CalculatorCViewController else { return }
        calculatorCViewController.insulinForFoodBoolean = insulinForFoodBoolean
        calculatorCViewController.insulinForHighBloodSugarBoolean = insulinForHighBloodSugarBoolean
        
        calculatorCViewController.totalCarbs = totalCarbs
        calculatorCViewController.carbRatio = carbRatio
        calculatorCViewController.bloodSugar = bloodSugar
        calculatorCViewController.targetBloodSugar = targetBloodSugar
        calculatorCViewController.correctionFactor = correctionFactor
        
        if let editViewController = segue.destination as? CalculatorEditViewController {
            editViewController.delegate = self
        }
    }
    
    @objc func dismissKeyboard() {
        // To hide the keyboard when the user clicks search
        self.view.endEditing(true)
        calculateFoodInsulin()
    }
    
    func roundDownToNearestHalf(value: Float) -> Float {
        let integerPart = floor(value)
        let decimalPart = value - integerPart

        if decimalPart >= 0.5 {
            return integerPart + 0.5
        } else {
            return integerPart
        }
    }
    
    func calculateFoodInsulin() {
        let currentBloodSugar = bloodSugar
        var currentTargetBloodSugar = targetBloodSugar
        var currentCorrectionFactor = correctionFactor

        // Fallback to stored constants if fields are empty
        if constantsManager.hasStoredConstants {
            let constants = constantsManager.getConstants()

            if currentTargetBloodSugar == 0, constants.targetBloodSugar > 0 {
                currentTargetBloodSugar = constants.targetBloodSugar
                targetBloodSugar = constants.targetBloodSugar
                targetBloodSugarField.text = String(constants.targetBloodSugar)
            }

            if currentCorrectionFactor == 0, constants.correctionFactor > 0 {
                currentCorrectionFactor = constants.correctionFactor
                correctionFactor = constants.correctionFactor
                correctionFactorField.text = String(constants.correctionFactor)
            }
        }

        // Only calculate if all required values are present
        if currentBloodSugar != 0 && currentTargetBloodSugar != 0 && currentCorrectionFactor != 0 {
            UIView.animate(withDuration: 0.2) {
                self.resultsView.isHidden = false
            }

            var bloodInsulin: Float = 0.0

            if insulinForHighBloodSugarBoolean && currentBloodSugar >= currentTargetBloodSugar {
                bloodInsulin = roundDownToNearestHalf(
                    value: Float(currentBloodSugar - currentTargetBloodSugar) / Float(currentCorrectionFactor)
                )

                bloodSugarLine.backgroundColor = .primaryBlue
                bloodSugarLabel.textColor = .primaryBlue
                bloodSugarField.textColor = .primaryBlue

                insulinForHighBloodSugar.text = "\(bloodInsulin.cleanString) units"
                insulinForHighBloodSugar.font = .gothamRoundedMedium32
                insulinForHighBloodSugar.textColor = .primaryBlue
            } else {
                insulinForHighBloodSugar.text = "No insulin needed if current blood sugar is below target."
                insulinForHighBloodSugar.font = .gothamRoundedMedium18
                insulinForHighBloodSugar.textColor = .orangeTextColor
                bloodSugarLine.backgroundColor = .orangeTextColor
                bloodSugarLabel.textColor = .orangeTextColor
            }
        } else {
            resultsView.isHidden = true
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
