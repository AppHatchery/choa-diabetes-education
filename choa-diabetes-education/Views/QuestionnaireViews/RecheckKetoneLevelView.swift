//
//  RecheckKetoneLevelView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 08/09/2025.
//

import Foundation
import UIKit

protocol RecheckKetoneLevelViewProtocol: AnyObject {
	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: SixOptionsAnswer)

	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: ThreeOptionsAnswer)

	func didSelectExitAction()

	func didSelectLearnHowAction()
}

class RecheckKetoneLevelView: UIView, UrineKetoneLevelView.UrineKetoneLevelDelegate, BloodKetoneLevelView.BloodKetoneLevelDelegate {
	func urineKetoneFollowUpView(_ view: UrineKetoneLevelView, didSelect answer: Int) {
		self.followUpAnswer = answer

		nextButton.alpha = 1
		nextButton.isEnabled = true
	}

	func bloodKetoneFollowUpView(_ view: BloodKetoneLevelView, didSelect answer: Int) {
		self.followUpAnswer = answer

		nextButton.alpha = 1
		nextButton.isEnabled = true
	}

	static let nibName = "RecheckKetoneLevelView"

	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var nextButton: PrimaryButton!
	@IBOutlet var exitButton: UIButton!

	@IBOutlet var ketoneMeasuringTypeStackView: UIStackView!

	@IBOutlet var resourcesStackView: UIStackView!
	@IBOutlet var learnHowLabel: UILabel!

	@IBOutlet var switchToLabel: UILabel!

	private var currentQuestion: Questionnaire!
	private var followUpQuestion: Questionnaire?

	private let questionnaireManager: QuestionnaireManager = QuestionnaireManager.instance

	weak var delegate: RecheckKetoneLevelViewProtocol?

	private var selected = 0
	private var followUpAnswer = 0

	private var followUpSubview = UrineKetoneLevelView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		nibSetup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		nibSetup()
	}

	private func nibSetup() {
		Bundle.main.loadNibNamed(RecheckKetoneLevelView.nibName, owner: self)
		addSubview(contentView)
		contentView.frame = self.bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}

	func setupView(currentQuestion: Questionnaire) {
		self.currentQuestion = currentQuestion

		nextButton.titleLabel?.font = .gothamRoundedMedium20
		exitButton.titleLabel?.font = .gothamRoundedMedium20

		setupLearnHowLabel()
		setupSwitchToLabel()

		if followUpAnswer == 0 {
			nextButton.alpha = 0.3
			nextButton.titleLabel?.font = .gothamRoundedMedium20
		}

		if questionnaireManager.currentMeasuringMethod == .urineKetone {
			selected = 1
			switchToUrineKetoneButtonTap()
		} else {
			selected = 2
			switchToBloodKetoneButtonTap()
		}

		if questionnaireManager.currentMeasuringMethod == .urineKetone {
		} else if questionnaireManager.currentMeasuringMethod == .bloodKetone {
		}
	}

	func toggleUrineAndBloodKetone() {
		if questionnaireManager.currentMeasuringMethod == .urineKetone {
			switchToBloodKetoneButtonTap()
			setupSwitchToLabel()
		} else if questionnaireManager.currentMeasuringMethod == .bloodKetone {
			switchToUrineKetoneButtonTap()
			setupSwitchToLabel()
		}
	}

	private func setupLearnHowLabel() {
			// Create underlined attributed text
		let text = "Learn how to measure ketones"
		let attributedString = NSMutableAttributedString(string: text)
		attributedString.addAttribute(.underlineStyle,
									  value: NSUnderlineStyle.single.rawValue,
									  range: NSRange(location: 0, length: text.count))

		attributedString.addAttribute(.foregroundColor,
									  value: UIColor.primaryBlue,
									  range: NSRange(location: 0, length: text.count))

		learnHowLabel.attributedText = attributedString

			// Make it tappable
		learnHowLabel.isUserInteractionEnabled = true
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(learnHowLabelTapped))
		learnHowLabel.addGestureRecognizer(tapGesture)
	}

	func setupSwitchToLabel() {
		let text = questionnaireManager.currentMeasuringMethod == .urineKetone ? "Switch to Blood Ketone" : "Switch to Urine Ketone"

		let attributedString = NSMutableAttributedString(string: text)
		attributedString.addAttribute(.underlineStyle,
									  value: NSUnderlineStyle.single.rawValue,
									  range: NSRange(location: 0, length: text.count))
		attributedString.addAttribute(.foregroundColor, value: UIColor.primaryBlue, range: NSRange(location: 0, length: text.count))
		switchToLabel.attributedText = attributedString

		switchToLabel.isUserInteractionEnabled = true
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(switchToLabelTapped))
		switchToLabel.addGestureRecognizer(tapGesture)
	}

	@objc private func learnHowLabelTapped() {
		delegate?.didSelectLearnHowAction()
	}

	@objc private func switchToLabelTapped() {
		toggleUrineAndBloodKetone()

		nextButton.alpha = 0.3
		nextButton.isEnabled = false
	}

	func switchToUrineKetoneButtonTap() {
		selected = 1
		questionnaireManager.saveMeasuringMethod(.urineKetone)

		if selected == 1 {
				// Guard against adding duplicate UrineKetoneLevelView
			if ketoneMeasuringTypeStackView.subviews.contains(where: { $0 is UrineKetoneLevelView }) {
				return
			}

				// Clear any existing subviews
			ketoneMeasuringTypeStackView.subviews.forEach { $0.removeFromSuperview() }

				// Show urine ketone level view
			let followUpSubview = UrineKetoneLevelView()

			followUpSubview.translatesAutoresizingMaskIntoConstraints = false
			ketoneMeasuringTypeStackView.addArrangedSubview(followUpSubview)

			NSLayoutConstraint.activate([
				followUpSubview.leadingAnchor.constraint(equalTo: ketoneMeasuringTypeStackView.leadingAnchor),
				followUpSubview.trailingAnchor.constraint(equalTo: ketoneMeasuringTypeStackView.trailingAnchor)
			])

			followUpSubview.delegate = self
		}
	}

	func switchToBloodKetoneButtonTap() {
			// Guard against adding duplicate BloodKetoneLevelView
		selected = 2
		questionnaireManager.saveMeasuringMethod(.bloodKetone)

		if selected == 2 {
			if ketoneMeasuringTypeStackView.subviews.contains(where: { $0 is BloodKetoneLevelView }) {
				return
			}


				// Clear any existing subviews
			ketoneMeasuringTypeStackView.subviews.forEach { $0.removeFromSuperview() }

				// Show blood ketone level view
			let followUpSubview = BloodKetoneLevelView()

			followUpSubview.translatesAutoresizingMaskIntoConstraints = false
			ketoneMeasuringTypeStackView.addArrangedSubview(followUpSubview)

			NSLayoutConstraint.activate([
				followUpSubview.leadingAnchor.constraint(equalTo: ketoneMeasuringTypeStackView.leadingAnchor),
				followUpSubview.trailingAnchor.constraint(equalTo: ketoneMeasuringTypeStackView.trailingAnchor)
			])

			followUpSubview.delegate = self
		}
	}

	@IBAction func didNextButtonTap(_ sender: UIButton) {

			// TODO: Architecture Discussion -> Switch Logic to VC

		if selected == 0 { return }

		if questionnaireManager.yesOver2hours == true {
			guard followUpAnswer != 0 else { return }

			if selected == 1 {
					// Urine ketones selected
				let answerEnum = UrineKetoneLevel(id: followUpAnswer)
				questionnaireManager.saveMeasuringMethod(.urineKetone)

				delegate?.didSelectNextAction(
					currentQuestion: currentQuestion,
					selectedAnswer: .UrineKetoneLevel(answerEnum)
				)
			} else if selected == 2 {
					// Blood ketones selected
				let answerEnum = BloodKetoneLevel(id: followUpAnswer)
				questionnaireManager.saveMeasuringMethod(.bloodKetone)

				delegate?.didSelectNextAction(
					currentQuestion: currentQuestion,
					selectedAnswer: .BloodKetoneLevel(answerEnum)
				)
			}
		}
	}


	@IBAction func didTapExitButton(_ sender: UIButton) {
		delegate?.didSelectExitAction()
	}

}
