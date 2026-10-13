//
//  ThreeOptionQueView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 13/10/2026.
//

import UIKit

protocol ThreeOptionQueViewProtocol: AnyObject {
	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: LowBloodSugarRecheckAnswer)
}

/// Two picture options side by side, and a third full-width option below them.
/// Picking the third option asks for the blood sugar reading before continuing.
class ThreeOptionQueView: UIView {
	static let nibName = "ThreeOptionQueView"

	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var mainStackView: UIStackView!
	@IBOutlet weak var questionLabel: UILabel!

	/// The options, tagged 1 to 3 in answer order: the two picture options, then the third option
	@IBOutlet var optionViews: [UIView]!
	@IBOutlet var optionLabels: [UILabel]!
	@IBOutlet var optionImages: [UIImageView]!

	@IBOutlet weak var followUpQuestionView: UIView!
	@IBOutlet weak var followUpQuestionLabel: UILabel!
	@IBOutlet weak var textFieldBorderView: UIView!
	@IBOutlet weak var bloodSugarTextField: UITextField!
	@IBOutlet weak var inputUnitLabel: UILabel!

	@IBOutlet weak var nextButton: PrimaryButton!

	private var currentQuestion: Questionnaire!
	weak var delegate: ThreeOptionQueViewProtocol?

	/// 1 and 2 are the picture options, 3 asks for the reading. 0 until one is picked.
	private var selected = 0

	private static let readingOption = 3

	override init(frame: CGRect) {
		super.init(frame: frame)
		nibSetup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		nibSetup()
	}

	private func nibSetup() {
		Bundle.main.loadNibNamed(ThreeOptionQueView.nibName, owner: self)
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

	func setupView(currentQuestion: Questionnaire) {
		self.currentQuestion = currentQuestion

		questionLabel.font = .nunitoSemiBold18
		questionLabel.numberOfLines = 0
		questionLabel.textColor = .headingGreenColor
		questionLabel.text = currentQuestion.question
		questionLabel.textAlignment = .left

		optionImages.forEach {
			$0.layer.cornerRadius = 8
		}

		// Outlet collections aren't guaranteed to keep their order, so each option view and label is tagged with its answer number
		optionViews.sort { $0.tag < $1.tag }
		optionLabels.sort { $0.tag < $1.tag }

		if let answerOptions = currentQuestion.answerOptions {
			for (label, option) in zip(optionLabels, answerOptions) {
				label.text = option
			}
		}

		for view in optionViews {
			view.updateViewForDeselection()
			view.isUserInteractionEnabled = true
			view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(optionViewTapped(_:))))
		}

		followUpQuestionLabel.text = currentQuestion.subQuestion
		inputUnitLabel.text = currentQuestion.inputUnit

		textFieldBorderView.layer.cornerRadius = 8
		textFieldBorderView.layer.borderWidth = 1
		textFieldBorderView.layer.borderColor = UIColor.borderGrayColor.cgColor

		bloodSugarTextField.text = nil
		bloodSugarTextField.keyboardType = .numberPad
		bloodSugarTextField.addTarget(self, action: #selector(bloodSugarTextChanged(_:)), for: .editingChanged)

		followUpQuestionView.isHidden = true

		let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
		tap.cancelsTouchesInView = false
		tap.delegate = self
		contentView.addGestureRecognizer(tap)

		updateNextButtonState()
	}

	private var enteredBloodSugar: Int? {
		guard let text = bloodSugarTextField.text, let value = Int(text), value > 0 else { return nil }
		return value
	}

	private var canContinue: Bool {
		switch selected {
		case 0:
			return false
		case Self.readingOption:
			return enteredBloodSugar != nil
		default:
			return true
		}
	}

	private func updateNextButtonState() {
		nextButton.isEnabled = canContinue
		nextButton.alpha = canContinue ? 1 : 0.3
	}

	@objc private func optionViewTapped(_ sender: UITapGestureRecognizer) {
		guard let tappedView = sender.view else { return }
		selected = tappedView.tag

		for (view, label) in zip(optionViews, optionLabels) {
			if view.tag == selected {
				view.updateViewForSelection()
				label.updateLabelForSelection()
			} else {
				view.updateViewForDeselection()
				label.updateLabelForDeselection()
			}
		}

		let showsReading = selected == Self.readingOption
		if followUpQuestionView.isHidden == showsReading {
			UIView.animate(withDuration: 0.25) {
				self.followUpQuestionView.isHidden = !showsReading
				self.followUpQuestionView.alpha = showsReading ? 1 : 0
			}
		}

		if showsReading {
			bloodSugarTextField.becomeFirstResponder()
		} else {
			contentView.endEditing(true)
		}

		updateNextButtonState()
	}

	@objc private func bloodSugarTextChanged(_ sender: UITextField) {
		updateNextButtonState()
	}

	@objc private func viewTapped(_ sender: UITapGestureRecognizer) {
		contentView.endEditing(true)
	}

	@IBAction func didNextButtonTap(_ sender: UIButton) {
		guard canContinue else { return }

		contentView.endEditing(true)

		let answer: LowBloodSugarRecheckAnswer
		switch selected {
		case 1:
			answer = .vomiting
		case 2:
			answer = .lossOfConsciousness
		default:
			guard let bloodSugar = enteredBloodSugar else { return }
			answer = .neither(bloodSugar: bloodSugar)
		}

		delegate?.didSelectNextAction(currentQuestion: currentQuestion, selectedAnswer: answer)
	}

	/// Shrinks the content view by the keyboard overlap so the next button, pinned to its bottom, stays visible.
	@objc private func keyboardWillShow(_ notification: Notification) {
		guard !isHidden,
			  let userInfo = notification.userInfo,
			  let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
			  let window = window else { return }

		let keyboardFrameInView = convert(keyboardFrameEnd, from: window.screen.coordinateSpace)
		let overlapHeight = bounds.intersection(keyboardFrameInView).height

		guard overlapHeight > 0 else { return }

		var newFrame = bounds
		newFrame.size.height = max(bounds.height - overlapHeight, 0)
		animateAlongsideKeyboard(notification) {
			self.contentView.frame = newFrame
			self.contentView.layoutIfNeeded()
		}
	}

	@objc private func keyboardWillHide(_ notification: Notification) {
		animateAlongsideKeyboard(notification) {
			self.contentView.frame = self.bounds
			self.contentView.layoutIfNeeded()
		}
	}

	private func animateAlongsideKeyboard(_ notification: Notification, animations: @escaping () -> Void) {
		let userInfo = notification.userInfo
		let duration = (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
		let curveRaw = (userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
		let curve = UIView.AnimationOptions(rawValue: curveRaw << 16)

		UIView.animate(withDuration: duration, delay: 0, options: [curve, .beginFromCurrentState], animations: animations)
	}
}

extension ThreeOptionQueView: UIGestureRecognizerDelegate {
	/// Ignore taps on controls and options. Dismissing the keyboard resizes the content view,
	/// which moves the next button out from under the touch before it can register `touchUpInside`.
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		var view = touch.view
		while let current = view {
			if current is UIControl || optionViews.contains(current) { return false }
			view = current.superview
		}
		return true
	}
}
