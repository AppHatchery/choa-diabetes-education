//
//  AppOnboardingQuestionView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 21/09/2026.
//

import UIKit

/// Renders a single `AppOnboardingQuestion` from data: title/subtitle, the
/// matching input UI (option list or text fields), and the next button.
/// Owns every UI concern for the onboarding flow so its view controller only
/// has to track state and navigate between questions.

class AppOnboardingQuestionView: UIView {
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var questionSubtitleLabel: UILabel!
    /// Shown for `.singleSelect` questions; hidden otherwise.
    @IBOutlet private weak var selectStackView: UIStackView!
    /// Shown for `.openEndedInput`/`.openEndedMultipleInput` questions; hidden otherwise.
    @IBOutlet private weak var openEndedStackView: UIStackView!
    @IBOutlet private weak var nextButton: PrimaryButton!

    @IBOutlet private weak var selectOptionView: UIView!
    @IBOutlet weak var selectOptionViewHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var selectOptionLabel: UILabel!
    @IBOutlet private weak var openEndedOptionView: UIView!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var selectOptionImageView: UIImageView!

    /// Called whenever the answer for the current question changes.
    var onAnswerChanged: ((AppOnboardingAnswer) -> Void)?
    /// Called when the next button is tapped.
    var onNext: (() -> Void)?

    private var question: AppOnboardingQuestion = .userRole
    private var textFields: [UITextField] = []
    private var selectedOptionId: Int?

    // The storyboard's prototype rows, captured before they're cloned/removed so
    // later questions can still stamp out copies of them.
    private lazy var selectOptionTemplateData = archivedData(for: selectOptionView)
    private lazy var openEndedOptionTemplateData = archivedData(for: openEndedOptionView)

    override func awakeFromNib() {
        super.awakeFromNib()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        addGestureRecognizer(tapGesture)

        pinNextButtonAboveKeyboard()
    }

    /// Swaps the storyboard's safe-area bottom constraint for the keyboard layout guide, which sits
    /// at the safe area while the keyboard is hidden and rides on top of it while it's shown.
    /// The scroll view is pinned to the button's top, so it shrinks to match and the fields stay reachable.
    private func pinNextButtonAboveKeyboard() {
        let safeAreaBottomConstraint = constraints.first {
            $0.firstItem === safeAreaLayoutGuide && $0.firstAttribute == .bottom &&
            $0.secondItem === nextButton && $0.secondAttribute == .bottom
        }
        let spacing = safeAreaBottomConstraint?.constant ?? 10
        safeAreaBottomConstraint?.isActive = false

        keyboardLayoutGuide.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: spacing).isActive = true
    }

    func configure(with question: AppOnboardingQuestion, answer: AppOnboardingAnswer?) {
        self.question = question

        questionTitleLabel.text = question.title
        questionSubtitleLabel.text = question.subtitle
        questionSubtitleLabel.isHidden = question.subtitle == nil

        // Force the lazily captured template data before the stacks are cleared out below.
        _ = selectOptionTemplateData
        _ = openEndedOptionTemplateData

        clearStackView(selectStackView)
        clearStackView(openEndedStackView)
        textFields = []
        selectedOptionId = answer?.selectedOptionId

        switch question.type {
        case .singleSelect(let options):
            selectStackView.isHidden = false
            openEndedStackView.isHidden = true

            for option in options {
                guard let row = cloneTemplate(selectOptionTemplateData) else { continue }
                configureOption(row, with: option, isSelected: option.id == selectedOptionId)
                selectStackView.addArrangedSubview(row)
            }

        case .openEndedInput(let placeholder, let kind):
            selectStackView.isHidden = true
            openEndedStackView.isHidden = false

            guard let row = cloneTemplate(openEndedOptionTemplateData) else { break }
            let textField = configureField(row, label: nil, placeholder: placeholder, kind: kind)
            if case .text(let value)? = answer {
                textField.text = value
            }
            openEndedStackView.addArrangedSubview(row)
            textFields = [textField]

        case .openEndedMultipleInput(let fields):
            selectStackView.isHidden = true
            openEndedStackView.isHidden = false

            let values: [String]
            if case .multipleText(let savedValues)? = answer {
                values = savedValues
            } else {
                values = []
            }

            for (index, field) in fields.enumerated() {
                guard let row = cloneTemplate(openEndedOptionTemplateData) else { continue }
                let textField = configureField(row, label: field.label, placeholder: field.placeholder, kind: field.kind)
                if index < values.count {
                    textField.text = values[index]
                }
                textFields.append(textField)
                openEndedStackView.addArrangedSubview(row)
            }

            // Return moves on to the next field, and the last one dismisses the keyboard
            for (index, textField) in textFields.enumerated() {
                textField.returnKeyType = index < textFields.count - 1 ? .next : .done
            }
        }

        updateNextButtonState()
    }

    private func clearStackView(_ stackView: UIStackView) {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    // MARK: - Template cloning

    /// Archives a storyboard-designed prototype row so it can be stamped out
    /// multiple times (once per option/field) without touching Interface Builder.
    private func archivedData(for view: UIView) -> Data {
        (try? NSKeyedArchiver.archivedData(withRootObject: view, requiringSecureCoding: false)) ?? Data()
    }

    private func cloneTemplate(_ data: Data) -> UIView? {
        try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIView
    }

    private func configureOption(_ row: UIView, with option: AppOnboardingOption, isSelected: Bool) {
        row.tag = option.id

        if let imageView = row.firstSubview(ofType: UIImageView.self) {
            imageView.image = option.imageName.flatMap { UIImage(named: $0) }
            imageView.isHidden = option.imageName == nil
            // NSKeyedArchiver doesn't carry raw CALayer properties across the
            // template clone, so this has to be (re)applied on every copy.
            imageView.layer.cornerRadius = 8
            imageView.layer.masksToBounds = true

            // The row's height constraint is cloned along with it, so mutate
            // the clone's constant rather than adding a new constraint.
            if let heightConstraint = row.constraints.first(where: { $0.firstAttribute == .height }) {
                heightConstraint.constant = option.imageName != nil ? 100 : 64
            }
        }
        
        row.firstSubview(ofType: UILabel.self)?.text = option.title
        setSelected(isSelected, on: row)

        row.gestureRecognizers?.forEach(row.removeGestureRecognizer)
        row.isUserInteractionEnabled = true
        row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOption(_:))))
    }

    /// Applies (or removes) the selected styling on an option row, including
    /// switching `selectOptionLabel` to white so it reads against the filled background.
    private func setSelected(_ isSelected: Bool, on row: UIView) {
        isSelected ? row.updateViewForSelection() : row.updateViewForDeselection()
        row.firstSubview(ofType: UILabel.self)?.textColor = isSelected ? .white : .primaryBlue
    }

    @discardableResult
    private func configureField(_ row: UIView, label: String?, placeholder: String, kind: AppOnboardingInputKind) -> UITextField {
        if let labelView = row.firstSubview(ofType: UILabel.self) {
            labelView.text = label
            labelView.isHidden = label == nil
        }

        let textField = row.firstSubview(ofType: UITextField.self) ?? UITextField()
        textField.placeholder = placeholder
        applyKeyboard(for: kind, to: textField)
        textField.delegate = self
        textField.removeTarget(nil, action: nil, for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        // NSKeyedArchiver doesn't carry raw CALayer properties across the
        // template clone, so the border has to be (re)applied on every copy.
        if let container = textField.superview {
            container.layer.borderWidth = 1
            container.layer.borderColor = UIColor.primaryBlue.cgColor
            container.layer.cornerRadius = 8
            container.layer.masksToBounds = true
        }

        return textField
    }

    /// Cloned rows keep whatever traits the previous question gave them, so every trait is set here
    private func applyKeyboard(for kind: AppOnboardingInputKind, to textField: UITextField) {
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no

        switch kind {
        case .name:
            textField.keyboardType = .default
            textField.autocapitalizationType = .words
            textField.textContentType = .organizationName
        case .county:
            textField.keyboardType = .default
            textField.autocapitalizationType = .words
            textField.textContentType = nil
        case .state:
            textField.keyboardType = .default
            textField.autocapitalizationType = .words
            textField.textContentType = .addressState
        case .postalCode:
            textField.keyboardType = .numberPad
            textField.autocapitalizationType = .none
            textField.textContentType = .postalCode
        case .age:
            textField.keyboardType = .numberPad
            textField.autocapitalizationType = .none
            textField.textContentType = nil
        }
    }

    // MARK: - Selection & input handling

    @objc private func didTapOption(_ gesture: UITapGestureRecognizer) {
        guard let row = gesture.view else { return }

        selectedOptionId = row.tag
        onAnswerChanged?(.selection(row.tag))

        for view in selectStackView.arrangedSubviews {
            setSelected(view.tag == row.tag, on: view)
        }

        updateNextButtonState()
    }

    @objc private func textFieldDidChange() {
        saveTextFieldAnswer()
        updateNextButtonState()
    }

    private func saveTextFieldAnswer() {
        switch question.type {
        case .openEndedInput:
            onAnswerChanged?(.text(textFields.first?.text ?? ""))
        case .openEndedMultipleInput:
            onAnswerChanged?(.multipleText(textFields.map { $0.text ?? "" }))
        case .singleSelect:
            break
        }
    }

    private func updateNextButtonState() {
        let isValid: Bool
        switch question.type {
        case .singleSelect:
            isValid = selectedOptionId != nil
        case .openEndedInput:
            isValid = !(textFields.first?.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
        case .openEndedMultipleInput:
            isValid = textFields.allSatisfy { !($0.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty }
        }

        nextButton.isEnabled = isValid
        nextButton.alpha = isValid ? 1.0 : 0.5
    }

    @objc private func dismissKeyboard() {
        endEditing(true)
    }

    @IBAction private func didTapNextButton(_ sender: Any) {
        saveTextFieldAnswer()
        onNext?()
    }
}

extension AppOnboardingQuestionView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let index = textFields.firstIndex(of: textField), index < textFields.count - 1 {
            textFields[index + 1].becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

private extension UIView {
    func firstSubview<T: UIView>(ofType type: T.Type) -> T? {
        for subview in subviews {
            if let match = subview as? T {
                return match
            }
            if let match = subview.firstSubview(ofType: type) {
                return match
            }
        }
        return nil
    }
}
