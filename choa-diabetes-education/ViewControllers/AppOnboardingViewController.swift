//
//  AppOnboardingViewController.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 21/09/2026.
//

import UIKit

class AppOnboardingViewController: UIViewController {
    static let storyboardIdentifier = "appOnboardingQuestion"

    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionSubtitleLabel: UILabel!
    @IBOutlet weak var selectStackView: UIStackView!
    @IBOutlet weak var openEndedStackView: UIStackView!
    @IBOutlet weak var nextButton: PrimaryButton!

    // Which question this screen instance shows, and every answer collected so far
    var currentQuestion: AppOnboardingQuestion = .userRole
    var answers: [AppOnboardingQuestion: AppOnboardingAnswer] = [:]

    private var textFields: [UITextField] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "App Onboarding"

        setupQuestion()
        updateNextButtonState()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupQuestion() {
        questionTitleLabel.text = currentQuestion.title
        questionSubtitleLabel.text = currentQuestion.subtitle
        questionSubtitleLabel.isHidden = currentQuestion.subtitle == nil

        optionsStackView.arrangedSubviews.forEach {
            optionsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        textFields = []

        switch currentQuestion.type {
        case .singleSelect(let options):
            let selectedOptionId = answers[currentQuestion]?.selectedOptionId
            for option in options {
                let row = makeOptionRow(for: option, isSelected: option.id == selectedOptionId)
                optionsStackView.addArrangedSubview(row)
            }

        case .openEndedInput(let placeholder):
            let field = makeTextField(placeholder: placeholder)
            if case .text(let value)? = answers[currentQuestion] {
                field.text = value
            }
            optionsStackView.addArrangedSubview(field)
            textFields = [field]

        case .openEndedMultipleInput(let fields):
            let values: [String]
            if case .multipleText(let savedValues)? = answers[currentQuestion] {
                values = savedValues
            } else {
                values = []
            }

            for (index, field) in fields.enumerated() {
                let textField = makeTextField(placeholder: field.placeholder)
                if index < values.count {
                    textField.text = values[index]
                }
                textFields.append(textField)
                optionsStackView.addArrangedSubview(makeLabeledField(label: field.label, textField: textField))
            }
        }
    }

    // MARK: - Row building

    private func makeOptionRow(for option: AppOnboardingOption, isSelected: Bool) -> UIView {
        let row = UIView()
        row.tag = option.id
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 60).isActive = true
        isSelected ? row.updateViewForSelection() : row.updateViewForDeselection()

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 8
        stack.isUserInteractionEnabled = false

        if let imageName = option.imageName, let image = UIImage(named: imageName) {
            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            stack.addArrangedSubview(imageView)
        }

        let label = UILabel()
        label.text = option.title
        label.font = .systemFont(ofSize: 17)
        label.textColor = .primaryBlue
        label.numberOfLines = 0
        stack.addArrangedSubview(label)

        row.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor, constant: -10),
            stack.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOption(_:)))
        row.addGestureRecognizer(tapGesture)

        return row
    }

    private func makeTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }

    private func makeLabeledField(label: String, textField: UITextField) -> UIView {
        let stack = UIStackView(arrangedSubviews: [{
            let labelView = UILabel()
            labelView.text = label
            labelView.font = .systemFont(ofSize: 14)
            labelView.textColor = .primaryBlue
            return labelView
        }(), textField])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }

    // MARK: - Selection & input handling

    @objc private func didTapOption(_ gesture: UITapGestureRecognizer) {
        guard let row = gesture.view else { return }

        answers[currentQuestion] = .selection(row.tag)

        for view in optionsStackView.arrangedSubviews {
            view.tag == row.tag ? view.updateViewForSelection() : view.updateViewForDeselection()
        }

        updateNextButtonState()
    }

    @objc private func textFieldDidChange() {
        saveTextFieldAnswers()
        updateNextButtonState()
    }

    private func saveTextFieldAnswers() {
        switch currentQuestion.type {
        case .openEndedInput:
            answers[currentQuestion] = .text(textFields.first?.text ?? "")
        case .openEndedMultipleInput:
            answers[currentQuestion] = .multipleText(textFields.map { $0.text ?? "" })
        case .singleSelect:
            break
        }
    }

    private func updateNextButtonState() {
        let isValid: Bool
        switch currentQuestion.type {
        case .singleSelect:
            isValid = answers[currentQuestion]?.selectedOptionId != nil
        case .openEndedInput:
            isValid = !(textFields.first?.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
        case .openEndedMultipleInput:
            isValid = textFields.allSatisfy { !($0.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty }
        }

        nextButton.isEnabled = isValid
        nextButton.alpha = isValid ? 1.0 : 0.5
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Navigation

    @IBAction func didTapNextButton(_ sender: Any) {
        saveTextFieldAnswers()

        let selectedOptionId = answers[currentQuestion]?.selectedOptionId

        if let nextQuestion = currentQuestion.next(selectedOptionId: selectedOptionId) {
            let storyboard = UIStoryboard(name: "AppOnboarding", bundle: nil)
            if let nextViewController = storyboard.instantiateViewController(withIdentifier: AppOnboardingViewController.storyboardIdentifier) as? AppOnboardingViewController {
                nextViewController.currentQuestion = nextQuestion
                nextViewController.answers = answers
                navigationController?.pushViewController(nextViewController, animated: true)
            }
        } else {
            finishOnboarding()
        }
    }

    private func finishOnboarding() {
        guard let window = view.window else { return }

        let mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = mainViewController
        })
    }
}

extension AppOnboardingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
