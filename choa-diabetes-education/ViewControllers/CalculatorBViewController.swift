//
//  CalculatorBViewController.swift
//  choa-diabetes-education
//
//  Created by Yago Arconada on 1/3/23.
//

import UIKit
import Lottie
import Pendo

class CalculatorBViewController: UIViewController, UITextFieldDelegate, CalculatorEditDelegate {
    
    @IBOutlet weak var bloodSugarField: UITextField!
    @IBOutlet weak var targetBloodSugarField: UITextField!
    @IBOutlet weak var targetBloodSugarLine: UIView!
    @IBOutlet weak var targetBloodSugarLabel: UILabel!
    @IBOutlet weak var correctionFactorField: UITextField!
    @IBOutlet weak var correctionFactorLine: UIView!
    @IBOutlet weak var correctionFactorLabel: UILabel!
    @IBOutlet weak var correctionFactorInfoButton: UIButton!
    @IBOutlet weak var targetBloodSugarInfoButton: UIButton!
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
    @IBOutlet weak var willImageView: UIImageView!

    // Full-screen Halloween overlay; it ignores touches so the fields stay usable
    private let batFlyby = LottieAnimationView(name: "bats-flyby")

    let infoPopup = InfoPopUpViewController()
    
    var totalCarbs: Int = 0
    var bloodSugar: Int = 0
    var targetBloodSugar: Int = 0
    var carbRatio: Int = 0
    var correctionFactor: Int = 0
    
    var insulinForHighBloodSugarBoolean = false
    var insulinForFoodBoolean = false
    var highBloodSugarOnly = false
    
    private var isUserEditingFields = false
    private var isShowingBelowTargetWarning = false

    /// Fields flagged as missing by the Next button; their error tracks the field's text from then on
    private var fieldsWithMissingValueError = Set<UITextField>()
    private var defaultLineColors = [UIView: UIColor]()

    /// Uses the fields' live text so it's accurate mid-edit
    private var isBloodSugarBelowTarget: Bool {
        let currentBloodSugarValue = Int(bloodSugarField.text ?? "") ?? 0
        let currentTargetValue = Int(targetBloodSugarField.text ?? "") ?? 0
        return currentBloodSugarValue > 0 && currentTargetValue > 0 && currentBloodSugarValue < currentTargetValue
    }

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
        applyTheme()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .halloweenThemeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(constantsDidChange), name: .calculatorConstantsDidChange, object: nil)

        setupBatFlyby()

        var config = UIButton.Configuration.plain()
        config.title = "Edit"
        config.image = UIImage(named: "edit_pencil")
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        config.baseForegroundColor = .black
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .nunito16
            return out
        }

        let button = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
            self?.editButtonTapped()
        })

        let editButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = editButton

        
        for txtField in textFieldCollection {
            txtField.delegate = self
        }
        
        bloodSugarField.addTarget(self, action: #selector(textFieldEditingDidBegin(_:)), for: .editingDidBegin)
        targetBloodSugarField.addTarget(self, action: #selector(textFieldEditingDidBegin(_:)), for: .editingDidBegin)
        correctionFactorField.addTarget(self, action: #selector(textFieldEditingDidBegin(_:)), for: .editingDidBegin)
        
        bloodSugarField.addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: .editingDidEnd)
        targetBloodSugarField.addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: .editingDidEnd)
        correctionFactorField.addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: .editingDidEnd)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        bloodSugarField.addTarget(self, action: #selector(textFieldsDidChange(_:)), for: .editingChanged)
        targetBloodSugarField.addTarget(self, action: #selector(textFieldsDidChange(_:)), for: .editingChanged)
        correctionFactorField.addTarget(self, action: #selector(textFieldsDidChange(_:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        bloodSugarLine.layer.cornerRadius = 3
        targetBloodSugarLine.layer.cornerRadius = 3
        correctionFactorLine.layer.cornerRadius = 3

        for line in [bloodSugarLine, targetBloodSugarLine, correctionFactorLine] {
            if let line, let color = line.backgroundColor {
                defaultLineColors[line] = color
            }
        }

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

            nextButton.applyExitStyle()
        }
        
        calculatorDidUpdateConstants()
        setupTappableInfoButtons()
        updateSeeResultAccessoryIfNeeded()
        updateNextButtonState()
    }
    
    @objc private func textFieldEditingDidBegin(_ sender: UITextField) {
        isUserEditingFields = true
    }

    @objc private func textFieldEditingDidEnd(_ sender: UITextField) {
        isUserEditingFields = false
    }
    
    @objc private func editButtonTapped() {
        performSegue(withIdentifier: "calculatorBToEditSegue", sender: nil)
    }

    // Swap in the Halloween Will and spiders when the theme is enabled in Remote Config
    @objc private func applyTheme() {
        let isHalloween = RemoteConfigManager.shared.isHalloweenThemeEnabled
        let imageName = isHalloween ? "halloween_will_insulin" : "will_calculator"
        willImageView.image = UIImage(named: imageName)

        batFlyby.isHidden = !isHalloween
        if isHalloween {
            batFlyby.play()
        } else {
            batFlyby.stop()
        }
    }

    private func setupBatFlyby() {
        batFlyby.contentMode = .scaleAspectFill
        batFlyby.loopMode = .loop
        batFlyby.backgroundBehavior = .pauseAndRestore
        batFlyby.isUserInteractionEnabled = false
        batFlyby.translatesAutoresizingMaskIntoConstraints = false

        // contentView starts below the nav bar, so the bats don't fly behind it
        contentView.addSubview(batFlyby)
        // Draw above every other subview, even ones added or brought to the front later
        batFlyby.layer.zPosition = 1

        // The animation is taller than the content view for its width, so pinning both edges let aspect fill
        // center it and crop the bats off the top. Matching its aspect ratio from the top keeps the flyby in view.
        let animationSize = batFlyby.animation?.size ?? CGSize(width: 1, height: 1)

        NSLayoutConstraint.activate([
            // Nudged up so the bats sit a little higher over the header
            batFlyby.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -24),
            batFlyby.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            batFlyby.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            batFlyby.heightAnchor.constraint(equalTo: batFlyby.widthAnchor, multiplier: animationSize.height / animationSize.width)
        ])
    }
    
    private func loadStoredConstants() {
        // Do not auto-fill while the user is actively editing/clearing
        if isUserEditingFields || targetBloodSugarField.isFirstResponder || correctionFactorField.isFirstResponder {
            return
        }

        guard constantsManager.hasStoredConstants else { return }
        let constants = constantsManager.getConstants()

        // Only populate if the field is currently empty AND not previously set by the user in this session
        if (targetBloodSugarField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           constants.targetBloodSugar > 0 {
            targetBloodSugar = constants.targetBloodSugar
            targetBloodSugarField.text = String(constants.targetBloodSugar)
        }

        if (correctionFactorField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           constants.correctionFactor > 0 {
            correctionFactor = constants.correctionFactor
            correctionFactorField.text = String(constants.correctionFactor)
        }

        // Recalculate with whatever is filled in; it hides the result if anything is missing
        calculateFoodInsulin()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("should begin tediting")
        // Removed clearing text to respect user input
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField.tag {
        case 0:
            bloodSugar = Int(textField.text ?? "0") ?? 0
            print(bloodSugar)
            if isBloodSugarBelowTarget {
                isShowingBelowTargetWarning = true
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
        
        hideErrorMessage()
        updateMissingValueError(for: textField)
        //        if (bloodSugar != 0 && targetBloodSugar != 0 && correctionFactor != 0) {
        //            nextButton.isEnabled = true
        //        } else {
        //            nextButton.isEnabled = false
        //        }
        updateSeeResultAccessoryIfNeeded()
        updateNextButtonState()
    }
    
    /// The error label wraps to fit its message, so clear the text too or a hidden
    /// multi-line message would still hold its height
    private func hideErrorMessage() {
        errorMessage.isHidden = true
        errorMessage.text = nil
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
    
    func seeCalculationViewSetup() {
        let accessoryView: UIView

        if #available(iOS 26.0, *) {
            // iOS 26+: system keyboard toolbar so the button renders as Liquid Glass
            let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
            let calculateItem = UIBarButtonItem(title: "Calculate", style: .prominent, target: self, action: #selector(self.dismissKeyboard))
            calculateItem.tintColor = UIColor.choaGreenColor
            toolbar.items = [.flexibleSpace(), calculateItem]
            toolbar.sizeToFit()
            accessoryView = toolbar
        } else {
            let customView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
            customView.backgroundColor = UIColor( red: 0xd5/255.0, green: 0xd8/255.0, blue: 0xdc/255.0, alpha: 1)

            let doneButton = UIButton( frame: CGRect( x: view.frame.width - 100 - 10, y: 0, width: 100, height: 44 ))
            doneButton.setTitle( "Calculate", for: .normal )
            doneButton.setTitleColor( UIColor.choaGreenColor, for: .normal)
            doneButton.addTarget( self, action: #selector( self.dismissKeyboard), for: .touchUpInside )
            customView.addSubview( doneButton )
            accessoryView = customView
        }

        bloodSugarField.inputAccessoryView = accessoryView
        targetBloodSugarField.inputAccessoryView = accessoryView
        correctionFactorField.inputAccessoryView = accessoryView
    }
    
    private func updateSeeResultAccessoryIfNeeded() {
        // Ensure both fields have text and their numeric values are > 0
        let hasBloodSugarText = !(bloodSugarField.text ?? "").trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
        let hasTargetBloodSugarText = !(targetBloodSugarField.text ?? "").trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
        let hasCorrectionFactorText = !(correctionFactorField.text ?? "").trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty

        let bloodSugarValue = Int(bloodSugarField.text ?? "") ?? 0
        let targetBloodSugarValue = Int(targetBloodSugarField.text ?? "") ?? 0
        let correctionFactorValue = Int(correctionFactorField.text ?? "") ?? 0

        let shouldShowAccessory = hasBloodSugarText && hasTargetBloodSugarText && hasCorrectionFactorText && bloodSugarValue > 0 && targetBloodSugarValue > 0 && correctionFactorValue > 0

        if shouldShowAccessory {
            seeCalculationViewSetup()
        } else {
            bloodSugarField.inputAccessoryView = nil
            targetBloodSugarField.inputAccessoryView = nil
            correctionFactorField.inputAccessoryView = nil
        }

        // Reload input views of the current first responder so changes take effect immediately
        if bloodSugarField.isFirstResponder {
            bloodSugarField.reloadInputViews()
        } else if targetBloodSugarField.isFirstResponder {
            targetBloodSugarField.reloadInputViews()
        } else if correctionFactorField.isFirstResponder {
            correctionFactorField.reloadInputViews()
        }
    }
    
    private func updateNextButtonState() {
        // Disable Next if both values are present and blood sugar is below target
        let currentBloodSugarValue = Int(bloodSugarField.text ?? "") ?? 0
        let currentTargetValue = Int(targetBloodSugarField.text ?? "") ?? 0
        let shouldDisable = currentBloodSugarValue > 0 && currentTargetValue > 0 && currentBloodSugarValue < currentTargetValue
        nextButton.isEnabled = !shouldDisable
        nextButton.alpha = shouldDisable ? 0.5 : 1.0
    }
    
    @objc private func textFieldsDidChange(_ sender: UITextField) {
        // Update backing values in real time
        if sender == bloodSugarField {
            bloodSugar = Int(sender.text ?? "") ?? 0
        } else if sender == targetBloodSugarField {
            targetBloodSugar = Int(sender.text ?? "") ?? 0
        } else if sender == correctionFactorField {
            correctionFactor = Int(sender.text ?? "") ?? 0
        }
        // Reflect UI/accessory state as user types
        updateSeeResultAccessoryIfNeeded()
        updateNextButtonState()
        updateMissingValueError(for: sender)

        if isShowingBelowTargetWarning && !isBloodSugarBelowTarget {
            clearBelowTargetWarning()
        } else if totalCarbs > 0 && carbRatio > 0 {
            calculateFoodInsulin()
        }
    }

    private func missingValueErrorParts(for field: UITextField) -> (line: UIView, label: UILabel, normalLabelColor: UIColor, message: String)? {
        switch field {
        case bloodSugarField:
            return (bloodSugarLine, bloodSugarLabel, .primaryBlue, "Calculator.BloodSugar.Number.Error".localized())
        case targetBloodSugarField:
            return (targetBloodSugarLine, targetBloodSugarLabel, .black, "Calculator.BloodSugar.Target.Error".localized())
        case correctionFactorField:
            return (correctionFactorLine, correctionFactorLabel, .black, "Calculator.BloodSugar.CF.Error".localized())
        default:
            return nil
        }
    }

    private func showMissingValueError(for field: UITextField) {
        guard let parts = missingValueErrorParts(for: field) else { return }
        fieldsWithMissingValueError.insert(field)
        toggleError(state: true, errorLine: parts.line, fieldLabel: parts.label, errorMessageText: parts.message)
        syncInfoIcons()
    }

    /// Clears a flagged field's error once it has a value, and brings it back if the value is deleted
    private func updateMissingValueError(for field: UITextField) {
        guard fieldsWithMissingValueError.contains(field),
              let parts = missingValueErrorParts(for: field) else { return }

        if (Int(field.text ?? "") ?? 0) > 0 {
            parts.line.backgroundColor = defaultLineColors[parts.line]
            parts.label.textColor = parts.normalLabelColor
            if errorMessage.text == parts.message {
                hideErrorMessage()
            }
        } else {
            toggleError(state: true, errorLine: parts.line, fieldLabel: parts.label, errorMessageText: parts.message)
        }
        syncInfoIcons()
    }

    /// Info icons sit beside their labels, so they follow the labels into and out of the error state
    private func syncInfoIcons() {
        correctionFactorInfoButton.tintColor = correctionFactorLabel.textColor
        targetBloodSugarInfoButton.tintColor = targetBloodSugarLabel.textColor
    }

    /// Back to the normal state once blood sugar is no longer below target,
    /// e.g. the target is lowered or blood sugar is raised mid-edit
    private func clearBelowTargetWarning() {
        isShowingBelowTargetWarning = false

        bloodSugarField.textColor = .primaryBlue
        bloodSugarLine.backgroundColor = .primaryBlue
        bloodSugarLabel.textColor = .primaryBlue
        insulinForHighBloodSugar.font = .nunitoBold32
        insulinForHighBloodSugar.textColor = .primaryBlue

        // Drop the warning text; recalculating shows the real dose if every field is filled
        resultsView.isHidden = true
        calculateFoodInsulin()
    }
    
    @IBAction func nextButton(_ sender: UIButton){
        self.view.endEditing(true)
        
        if highBloodSugarOnly == false {
            if (bloodSugar != 0 && targetBloodSugar != 0 && correctionFactor != 0){
                // Go to next page
                performSegue(withIdentifier: "SegueToCalculatorCViewController", sender: nil)
            } else if (bloodSugar != 0 && targetBloodSugar != 0 ) {
                // CarbRatio is not there
                showMissingValueError(for: correctionFactorField)
            } else if (bloodSugar != 0 && correctionFactor != 0) {
                // Target BG is not there
                showMissingValueError(for: targetBloodSugarField)
            } else if (targetBloodSugar != 0 && correctionFactor != 0) {
                // BG is not there
                showMissingValueError(for: bloodSugarField)
            } else {
                errorMessage.text = "Calculator.Carbs.MissingInfo.Error".localized()
                errorMessage.isHidden = false
            }
        } else {
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

    /// Saved values or the rounding rule changed, e.g. on the edit screen: refill empty fields
    /// and redo the result so it's rounded with the new rule
    @objc private func constantsDidChange() {
        guard isViewLoaded else { return }
        // Loading saved values recalculates on its own; with none saved, recalculate with what's typed in
        if constantsManager.hasStoredConstants {
            loadStoredConstants()
        } else {
            calculateFoodInsulin()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Checked first: the guard below returns for every destination but Calculator C
        if let editViewController = segue.destination as? CalculatorEditViewController {
            editViewController.delegate = self
        }

        guard let calculatorCViewController = segue.destination as? CalculatorCViewController else { return }
        calculatorCViewController.insulinForFoodBoolean = insulinForFoodBoolean
        calculatorCViewController.insulinForHighBloodSugarBoolean = insulinForHighBloodSugarBoolean
        
        calculatorCViewController.totalCarbs = totalCarbs
        calculatorCViewController.carbRatio = carbRatio
        calculatorCViewController.bloodSugar = bloodSugar
        calculatorCViewController.targetBloodSugar = targetBloodSugar
        calculatorCViewController.correctionFactor = correctionFactor
    }
    
    @objc func dismissKeyboard() {
        // To hide the keyboard when the user clicks search
        self.view.endEditing(true)
        updateSeeResultAccessoryIfNeeded()
        calculateFoodInsulin()
    }
    
    func calculateFoodInsulin() {
        let currentBloodSugar = bloodSugar
        var currentTargetBloodSugar = targetBloodSugar
        var currentCorrectionFactor = correctionFactor

        // Fallback to stored constants only when user is not editing AND fields are empty
        if !isUserEditingFields,
           !targetBloodSugarField.isFirstResponder,
           !correctionFactorField.isFirstResponder,
           constantsManager.hasStoredConstants {
            let constants = constantsManager.getConstants()

            if currentTargetBloodSugar == 0,
               (targetBloodSugarField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               constants.targetBloodSugar > 0 {
                currentTargetBloodSugar = constants.targetBloodSugar
                targetBloodSugar = constants.targetBloodSugar
                targetBloodSugarField.text = String(constants.targetBloodSugar)
            }

            if currentCorrectionFactor == 0,
               (correctionFactorField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               constants.correctionFactor > 0 {
                currentCorrectionFactor = constants.correctionFactor
                correctionFactor = constants.correctionFactor
                correctionFactorField.text = String(constants.correctionFactor)
            }
        }

        // If current blood sugar is below target, show warning and do not calculate
        if currentBloodSugar > 0 && currentTargetBloodSugar > 0 && currentBloodSugar < currentTargetBloodSugar {
            // Show results container with warning state
            isShowingBelowTargetWarning = true
            UIView.animate(withDuration: 0.2) {
                self.resultsView.isHidden = false
            }
            insulinForHighBloodSugar.text = "No insulin needed if current blood sugar is below target."
            insulinForHighBloodSugar.font = .nunitoBold18
            insulinForHighBloodSugar.textColor = .orangeTextColor
            insulinForHighBloodSugar.numberOfLines = 4
            bloodSugarLine.backgroundColor = .orangeTextColor
            bloodSugarLabel.textColor = .orangeTextColor
            bloodSugarField.textColor = .orangeTextColor
            updateSeeResultAccessoryIfNeeded()
            updateNextButtonState()
            return
        }
        
        // Only calculate if all required values are present
        if currentBloodSugar != 0 && currentTargetBloodSugar != 0 && currentCorrectionFactor != 0 {
            UIView.animate(withDuration: 0.2) {
                self.resultsView.isHidden = false
            }

            if insulinForHighBloodSugarBoolean && currentBloodSugar >= currentTargetBloodSugar {
                let bloodInsulin = InsulinDose.correction(bloodSugar: currentBloodSugar, targetBloodSugar: currentTargetBloodSugar, correctionFactor: currentCorrectionFactor)

                bloodSugarLine.backgroundColor = .primaryBlue
                bloodSugarLabel.textColor = .primaryBlue
                bloodSugarField.textColor = .primaryBlue

                // For meals + correction, only the combined total is rounded (on CalculatorC)
                insulinForHighBloodSugar.text = bloodInsulin.displayText(rounded: !insulinForFoodBoolean, using: constantsManager.roundingRule)
                insulinForHighBloodSugar.font = .nunitoBold32
                insulinForHighBloodSugar.textColor = .primaryBlue
                PendoManager.shared().track("Calculate_insulin_for_hbs", properties: ["blood_sugar": currentBloodSugar, "target_blood_sugar": currentTargetBloodSugar, "correction_factor": currentCorrectionFactor])
                updateNextButtonState()
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

