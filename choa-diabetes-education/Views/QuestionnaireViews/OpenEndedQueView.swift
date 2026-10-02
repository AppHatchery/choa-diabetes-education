//
//  OpenEndedQueView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol OpenEndedQueViewProtocol: AnyObject {
    func didSelectNextAction(currentQuestion: Questionnaire, bloodSugar: Int, cf: Int)

    func didSelectNextAction(currentQuestion: Questionnaire, bloodSugar: Int, durationOver300: HighBloodSugarDuration?)

    /// Called for the blood sugar recheck, which only asks for the reading.
    func didSelectNextAction(currentQuestion: Questionnaire, bloodSugar: Int)

    /// Called instead of `didSelectNextAction` when the reading is below the low blood sugar threshold.
    func didEnterLowBloodSugar(currentQuestion: Questionnaire, bloodSugar: Int)
}

class OpenEndedQueView: UIView {
    static let nibName = "OpenEndedQueView"

    /// Readings at or above this value show the duration follow-up question.
    private static let highBloodSugarThreshold = 300

    /// Readings below this value may be hypoglycemia, so confirm before continuing.
    private static let lowBloodSugarThreshold = 70

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var firstQueContentView: UIView!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var textFieldBorderView: UIView!
    @IBOutlet weak var bloodSugarTextField: UITextField!
    @IBOutlet weak var inputUnitLabel: UILabel!
    @IBOutlet weak var followUpQuestionView: UIView!
    @IBOutlet weak var followUpQuestionLabel: UILabel!
    @IBOutlet weak var slider: UISlider!

    @IBOutlet weak var questionLabel: UILabel!

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nextButton: PrimaryButton!

    private var currentQuestion: Questionnaire!
    weak var delegate: OpenEndedQueViewProtocol?

    /// The duration slider has no empty state, so require the user to move it
    /// before continuing rather than silently accepting the default value.
    private var hasSelectedDuration = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }

    private func nibSetup() {
        Bundle.main.loadNibNamed(OpenEndedQueView.nibName, owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    /// Shrinks the content view by the keyboard overlap so the next button, pinned to its bottom, stays visible.
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard !isHidden,
              let userInfo = notification.userInfo,
              let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let window = window else { return }

        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let curve = UIView.AnimationOptions(rawValue: curveRaw << 16)

        // Convert keyboard frame to this view's coordinate space
        let keyboardFrameInView = convert(keyboardFrameEnd, from: window.screen.coordinateSpace)
        let overlapHeight = bounds.intersection(keyboardFrameInView).height

        guard overlapHeight > 0 else { return }

        var newFrame = bounds
        newFrame.size.height = max(bounds.height - overlapHeight, 0)
        UIView.animate(withDuration: duration, delay: 0, options: [curve, .beginFromCurrentState], animations: {
            self.contentView.frame = newFrame
            self.contentView.layoutIfNeeded()
        }, completion: nil)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            contentView.frame = bounds
            return
        }

        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let curve = UIView.AnimationOptions(rawValue: curveRaw << 16)

        UIView.animate(withDuration: duration, delay: 0, options: [curve, .beginFromCurrentState], animations: {
            self.contentView.frame = self.bounds
            self.contentView.layoutIfNeeded()
        }, completion: nil)
    }

    func setupView(currentQuestion: Questionnaire, multiple: Bool) {
        self.currentQuestion = currentQuestion

        questionLabel.numberOfLines = 0
        questionLabel.text = currentQuestion.question
        questionLabel.textAlignment = .left
        
        textFieldBorderView.layer.cornerRadius = 8
        textFieldBorderView.layer.borderWidth = 1
        textFieldBorderView.layer.borderColor = UIColor.borderGrayColor.cgColor

        followUpQuestionLabel.text = currentQuestion.subQuestion
        inputUnitLabel.text = currentQuestion.inputUnit

        bloodSugarTextField.text = nil
        bloodSugarTextField.keyboardType = .numberPad
        bloodSugarTextField.addTarget(self, action: #selector(bloodSugarTextChanged(_:)), for: .editingChanged)

        slider.minimumValue = Float(HighBloodSugarDuration.allCases.first?.rawValue ?? 1)
        slider.maximumValue = Float(HighBloodSugarDuration.allCases.last?.rawValue ?? 7)
        slider.value = slider.minimumValue
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)

        hasSelectedDuration = false
        followUpQuestionView.isHidden = true

        updateNextButtonState()

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        tap.cancelsTouchesInView = false
        contentView.addGestureRecognizer(tap)
        contentView.isUserInteractionEnabled = true

        guard let description = currentQuestion.description, description != "" else {
            descriptionLabel.isHidden = true
            return
        }

        descriptionLabel.isHidden = false
        descriptionLabel.font = .arial14
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .headingGreenColor
        descriptionLabel.text = description
        descriptionLabel.textAlignment = .left
    }

    private var enteredBloodSugar: Int? {
        guard let text = bloodSugarTextField.text, let value = Int(text), value > 0 else { return nil }
        return value
    }

    private var isFollowUpRequired: Bool {
        // Only the first blood sugar check asks how long it's been above 300 mg/dL
        guard currentQuestion.questionType == .openEndedWithMultipleInput(.bloodSugarCheck),
              let bloodSugar = enteredBloodSugar else { return false }
        return bloodSugar >= OpenEndedQueView.highBloodSugarThreshold
    }

    private var canContinue: Bool {
        guard enteredBloodSugar != nil else { return false }
        return !isFollowUpRequired || hasSelectedDuration
    }

    private func updateNextButtonState() {
        nextButton.isEnabled = canContinue
        nextButton.alpha = canContinue ? 1 : 0.3
    }

    @objc private func bloodSugarTextChanged(_ sender: UITextField) {
        let shouldShowFollowUp = isFollowUpRequired
        if followUpQuestionView.isHidden == shouldShowFollowUp {
            UIView.animate(withDuration: 0.25) {
                self.followUpQuestionView.isHidden = !shouldShowFollowUp
                self.followUpQuestionView.alpha = shouldShowFollowUp ? 1 : 0
            }
        }
        updateNextButtonState()
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        // Snap to the nearest labeled step
        sender.value = sender.value.rounded()
        hasSelectedDuration = true
        updateNextButtonState()
    }

    @objc func viewTapped(_ sender: UITapGestureRecognizer?) {
        contentView.endEditing(true)
    }

    @IBAction func didNextButtonTap(_ sender: UIButton) {
        guard canContinue, let bloodSugar = enteredBloodSugar else { return }

        switch self.currentQuestion.questionType {
        case .openEndedWithMultipleInput(.bloodSugarCheck):
            if bloodSugar < OpenEndedQueView.lowBloodSugarThreshold {
                contentView.endEditing(true)
                delegate?.didEnterLowBloodSugar(currentQuestion: self.currentQuestion, bloodSugar: bloodSugar)
            } else {
                let duration = isFollowUpRequired ? HighBloodSugarDuration(rawValue: Int(slider.value)) : nil
                delegate?.didSelectNextAction(currentQuestion: self.currentQuestion, bloodSugar: bloodSugar, durationOver300: duration)
            }
        case .openEndedWithMultipleInput(.bloodSugarRecheck):
            contentView.endEditing(true)
            if bloodSugar < OpenEndedQueView.lowBloodSugarThreshold {
                delegate?.didEnterLowBloodSugar(currentQuestion: self.currentQuestion, bloodSugar: bloodSugar)
            } else {
                delegate?.didSelectNextAction(currentQuestion: self.currentQuestion, bloodSugar: bloodSugar)
            }
        default:
            return
        }
    }
}
