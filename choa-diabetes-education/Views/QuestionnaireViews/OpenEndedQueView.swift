//
//  OpenEndedQueView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol OpenEndedQueViewProtocol: AnyObject {
    func didSelectNextAction(currentQuestion: Questionnaire, bloodSugar: Int, cf: Int)

    func didSelectNextAction(currentQuestion: Questionnaire, bloodSugar: Int, durationOver300: HighBloodSugarDuration?)

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

        nextButton.layer.cornerRadius = 12
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
        guard let bloodSugar = enteredBloodSugar else { return false }
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
        default:
            return
        }
    }
}
