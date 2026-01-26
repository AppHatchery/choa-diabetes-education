//
//  CalculatorAViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 1/3/23.
//

import UIKit
import Pendo

protocol CalculatorResetDelegate: AnyObject {
    func resetCalculatorFields()
}

class CalculatorAViewController: UIViewController, UITextFieldDelegate, CalculatorEditDelegate {
    
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
    @IBOutlet weak var resultsView: UIView!
    @IBOutlet weak var insulinForFoodTitleLabel: UILabel!
    @IBOutlet weak var insulinForFood: UILabel!
    @IBOutlet weak var step1Label: UILabel!
    
    var totalCarbs: Int = 0
    var carbRatio: Int = 0
    var insulinForHighBloodSugarBoolean = false
    var insulinForFoodBoolean = true
    
    let infoPopup = InfoPopUpViewController()
    
    private let constantsManager = CalculatorConstantsManager.shared
    
    weak var resetDelegate: CalculatorResetDelegate?
    
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
        
        totalCarbsField.addTarget(self, action: #selector(textFieldsDidChange(_:)), for: .editingChanged)
        carbRatioField.addTarget(self, action: #selector(textFieldsDidChange(_:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        let mealsAndHighSugar = insulinForFoodBoolean && insulinForHighBloodSugarBoolean
        
        carbLine.layer.cornerRadius = 3
        carbRatioLine.layer.cornerRadius = 3
        
        resultsView.isHidden = true
        
        if mealsAndHighSugar {
            step1Label.isHidden = false

            nextButton.titleLabel?.text = "Next"
            nextButton.setImage(UIImage(named: "leftArrow"), for: .normal)
            nextButton.backgroundColor = .choaGreenColor
            nextButton.tintColor = .choaGreenColor
            nextButton.layer.cornerRadius = 12
        } else {
            step1Label.isHidden = true

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
        updateSeeResultAccessoryIfNeeded()
    }
    
    func resetCalculatorFields() {
        totalCarbs = 0
        carbRatio = 0
        
        totalCarbsField.text = ""
        carbRatioField.text = ""
        
        carbRatioLine.backgroundColor = .errorRedColor
        carbRatioLabel.textColor = .contentBlackColor
        totalCarbsField.textColor = .black
        
        resultsView.isHidden = true
        errorMessage.isHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func editButtonTapped() {
        // Handle edit action
        performSegue(withIdentifier: "calculatorAToEditSegue", sender: nil)
    }
    
    private func loadStoredConstants() {
            if constantsManager.hasStoredConstants {
                let constants = constantsManager.getConstants()
                print("Loaded constants - carbRatio: \(constants.carbRatio)")
                
                // NOTE: This updates the UI (text fields to be exact) with stored constants
                if constants.carbRatio > 0 {
                    carbRatio = constants.carbRatio
                    carbRatioField.text = String(constants.carbRatio)
                    
                    calculateFoodInsulin()
                }
            }
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
            totalCarbs = Int(textField.text ?? "0") ?? 0
            print(totalCarbs)
            carbLine.backgroundColor = .primaryBlue
//            toggleError(state: false, errorLine: carbLine, fieldLabel: carbLabel, errorMessageText: "")
            carbLine.tintColor = UIColor.errorRedColor
        case 1:
            carbRatio = Int(textField.text ?? "0") ?? 0
            print(carbRatio)
            carbRatioLabel.textColor = .black
//            toggleError(state: false, errorLine: carbRatioLine, fieldLabel: carbRatioLabel, errorMessageText: "")
        default:
            print("none of these")
        }
        
        errorMessage.isHidden = true
        updateSeeResultAccessoryIfNeeded()
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
    
    
    @objc func dismissKeyboard() {
        // To hide the keyboard when the user clicks search
        self.view.endEditing(true)
        updateSeeResultAccessoryIfNeeded()
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
        let currentTotalCarbs = totalCarbs
        var currentCarbRatio = carbRatio

        // If carb ratio is not entered manually, try to load from stored constants
        if currentCarbRatio == 0, constantsManager.hasStoredConstants {
            let constants = constantsManager.getConstants()
            if constants.carbRatio > 0 {
                currentCarbRatio = constants.carbRatio
                carbRatio = constants.carbRatio // Keep in sync
                carbRatioField.text = String(constants.carbRatio)
            }
        }

        // Only calculate if both values are present
        if currentTotalCarbs > 0 && currentCarbRatio > 0 {
            UIView.animate(withDuration: 0.2) {
                self.resultsView.isHidden = false
            }

            if insulinForFoodBoolean {
                let foodInsulin = roundDownToNearestHalf(
                    value: Float(currentTotalCarbs) / Float(currentCarbRatio)
                )
                
                insulinForFood.text = "\(foodInsulin.cleanString) units"
            }

            totalCarbsField.textColor = .primaryBlue
            carbLine.backgroundColor = .primaryBlue
            carbLabel.textColor = .primaryBlue
            
            updateSeeResultAccessoryIfNeeded()
        } else {
            resultsView.isHidden = true
        }
    }
    
    func seeCalculationViewSetup() {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        customView.backgroundColor = UIColor( red: 0xd5/255.0, green: 0xd8/255.0, blue: 0xdc/255.0, alpha: 1)

        let doneButton = UIButton( frame: CGRect( x: view.frame.width - 100 - 10, y: 0, width: 100, height: 44 ))
        doneButton.setTitle( "Calculate", for: .normal )
        doneButton.setTitleColor( UIColor.choaGreenColor, for: .normal)
        doneButton.addTarget( self, action: #selector( self.dismissKeyboard), for: .touchUpInside )
        customView.addSubview( doneButton )
        totalCarbsField.inputAccessoryView = customView
        carbRatioField.inputAccessoryView = customView
    }
    
    private func updateSeeResultAccessoryIfNeeded() {
        // Ensure both fields have text and their numeric values are > 0
        let hasCarbsText = !(totalCarbsField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasRatioText = !(carbRatioField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        let carbsValue = Int(totalCarbsField.text ?? "") ?? 0
        let ratioValue = Int(carbRatioField.text ?? "") ?? 0

        let shouldShowAccessory = hasCarbsText && hasRatioText && carbsValue > 0 && ratioValue > 0

        if shouldShowAccessory {
            seeCalculationViewSetup()
        } else {
            totalCarbsField.inputAccessoryView = nil
            carbRatioField.inputAccessoryView = nil
        }

        // Reload input views of the current first responder so changes take effect immediately
        if totalCarbsField.isFirstResponder {
            totalCarbsField.reloadInputViews()
        } else if carbRatioField.isFirstResponder {
            carbRatioField.reloadInputViews()
        }
    }
    
    @objc private func textFieldsDidChange(_ sender: UITextField) {
        // Update backing values in real time
        if sender == totalCarbsField {
            totalCarbs = Int(sender.text ?? "") ?? 0
        } else if sender == carbRatioField {
            carbRatio = Int(sender.text ?? "") ?? 0
        }
        // Reflect UI/accessory state as user types
        updateSeeResultAccessoryIfNeeded()
        
        if totalCarbs > 0 && carbRatio > 0 {
            calculateFoodInsulin()
        }
    }
    
    @IBAction func nextButton(_ sender: UIButton){
        self.view.endEditing(true)
        
        insulinForFoodBoolean = true
        
        if insulinForFoodBoolean && insulinForHighBloodSugarBoolean == true {
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
        } else if insulinForFoodBoolean == true && insulinForHighBloodSugarBoolean == false {
            
            if let viewControllers = self.navigationController?.viewControllers {
                for vc in viewControllers {
                    if vc is HomeViewController {
                        self.navigationController?.popToViewController(vc, animated: true)
                        return
                    }
                }
            }
        }
    }
    
    func setupTappableInfoButtons() {
        let showTotalCarbsInfoTap = UITapGestureRecognizer(target: self, action: #selector(didTapShowTotalCarbsInfo))
        carbLabel.addGestureRecognizer(showTotalCarbsInfoTap)
        carbLabel.isUserInteractionEnabled = true
        
        let showCarbRatioInfoTap = UITapGestureRecognizer(target: self, action: #selector(didTapShowCarbRatioInfo))
        carbRatioLabel.addGestureRecognizer(showCarbRatioInfoTap)
        carbRatioLabel.isUserInteractionEnabled = true

        
        let showInsulinForFoodInfoTap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapShowInsulinForFoodInfo))
        insulinForFoodTitleLabel.addGestureRecognizer(showInsulinForFoodInfoTap)
        insulinForFoodTitleLabel.isUserInteractionEnabled = true
    }
    
    @objc private func didTapShowTotalCarbsInfo() {
        showTotalCarbsInfo(self)
    }
    
    @objc private func didTapShowCarbRatioInfo() {
        showCarbRatioInfo(self)
    }
    
    @objc private func didTapShowInsulinForFoodInfo() {
        showInsulinForFoodInfo(self)
    }
    
    @IBAction func showTotalCarbsInfo(_ sender: Any) {
        infoPopup
            .appear(
                sender: self,
                title: "PopupInfo.TotalCarbs.title".localized()
                , details: "PopupInfo.TotalCarbs.text".localized())
    }
    
    @IBAction func showCarbRatioInfo(_ sender: Any) {
        infoPopup.appear(sender: self, title: "PopupInfo.CarbRatio.title".localized()
                         , details: "PopupInfo.CarbRatio.text".localized())
    }
    
    @IBAction func showInsulinForFoodInfo(_ sender: Any) {
        infoPopup.appear(sender: self, title: "PopupInfo.InsulinForFood.title".localized()
                         , details: "PopupInfo.InsulinForFood.text".localized())
    }
    
    
    func calculatorDidUpdateConstants() {
        loadStoredConstants()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let calculatorBViewController = segue.destination as? CalculatorBViewController {
            calculatorBViewController.insulinForFoodBoolean = insulinForFoodBoolean
            calculatorBViewController.insulinForHighBloodSugarBoolean = insulinForHighBloodSugarBoolean
            
            if totalCarbs > 0 && carbRatio > 0 {
                calculatorBViewController.totalCarbs = totalCarbs
                calculatorBViewController.carbRatio = carbRatio
            }
        }
        
        if let calculatorCViewController = segue.destination as? CalculatorCViewController {
            calculatorCViewController.insulinForFoodBoolean = insulinForFoodBoolean
            calculatorCViewController.insulinForHighBloodSugarBoolean = insulinForHighBloodSugarBoolean
            
            if totalCarbs > 0 && carbRatio > 0 {
                calculatorCViewController.totalCarbs = totalCarbs
                calculatorCViewController.carbRatio = carbRatio
            }
        }
        
        if let editViewController = segue.destination as? CalculatorEditViewController {
            editViewController.delegate = self
        }
    }
}
