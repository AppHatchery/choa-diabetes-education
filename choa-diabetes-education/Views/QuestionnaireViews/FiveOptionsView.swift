//
//  FiveOptionsView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol FiveOptionsViewProtocol: AnyObject {
    func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: FiveOptionsAnswer)
}

class FiveOptionsView: UIView {
	static let nibName = "FiveOptionsView"

	@IBOutlet weak var questionLabel: UILabel!
	@IBOutlet weak var firstButton: RoundedButton!
	@IBOutlet weak var secondButton: RoundedButton!
	@IBOutlet weak var thirdButton: RoundedButton!
	@IBOutlet weak var fourthButton: RoundedButton!
	@IBOutlet weak var fifthButton: RoundedButton!
	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var nextButton: PrimaryButton!

	private var currentQuestion: Questionnaire!
	weak var delegate: FiveOptionsViewProtocol?

	private var selected = 0

	override init(frame: CGRect) {
		super.init(frame: frame)
		nibSetup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		nibSetup()
	}

	private func nibSetup() {
		Bundle.main.loadNibNamed(FiveOptionsView.nibName, owner: self)
		addSubview(contentView)
		contentView.frame = self.bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}

	func setupView(currentQuestion: Questionnaire) {
		self.currentQuestion = currentQuestion
		questionLabel.font = .gothamRoundedMedium
		questionLabel.numberOfLines = 5
		questionLabel.textColor = .headingGreenColor
		questionLabel.text = currentQuestion.question
		questionLabel.textAlignment = .left

		if let answerOptions = currentQuestion.answerOptions {
			firstButton.setTitle(answerOptions[0].localized(), for: .normal)
			secondButton.setTitle(answerOptions[1].localized(), for: .normal)
			thirdButton.setTitle(answerOptions[2].localized(), for: .normal)
			fourthButton.setTitle(answerOptions[3].localized(), for: .normal)
			fifthButton.setTitle(answerOptions[4].localized(), for: .normal)
		}
	}

	@IBAction func didFirstButtonTap(_ sender: UIButton) {
		selected = 1
		firstButton.updateButtonForSelection()
		secondButton.updateButtonForDeselection()
		thirdButton.updateButtonForDeselection()
		fourthButton.updateButtonForDeselection()
		fifthButton.updateButtonForDeselection()
	}

	@IBAction func didSecondButtonTap(_ sender: UIButton) {
		selected = 2
		secondButton.updateButtonForSelection()
		firstButton.updateButtonForDeselection()
		thirdButton.updateButtonForDeselection()
		fourthButton.updateButtonForDeselection()
		fifthButton.updateButtonForDeselection()
	}

	@IBAction func didThirdButtonTap(_ sender: UIButton) {
		selected = 3
		thirdButton.updateButtonForSelection()
		secondButton.updateButtonForDeselection()
		firstButton.updateButtonForDeselection()
		fourthButton.updateButtonForDeselection()
		fifthButton.updateButtonForDeselection()
	}

	@IBAction func didFourthButtonTap(_ sender: UIButton) {
		selected = 4
		fourthButton.updateButtonForSelection()
		firstButton.updateButtonForDeselection()
		thirdButton.updateButtonForDeselection()
		secondButton.updateButtonForDeselection()
		fifthButton.updateButtonForDeselection()
	}

	@IBAction func didFifthButtonTap(_ sender: UIButton) {
		selected = 5
		fifthButton.updateButtonForSelection()
		firstButton.updateButtonForDeselection()
		thirdButton.updateButtonForDeselection()
		secondButton.updateButtonForDeselection()
		fourthButton.updateButtonForDeselection()
	}


	@IBAction func didNextButtonTap(_ sender: UIButton) {
		if selected == 0 { return }

		print("SELECTED: \(currentQuestion.questionId ?? 0)")

		switch currentQuestion.questionId {
			case FiveOptionsQuestionId.childHasAnySymptoms.id:
				if (selected == 5) {
					delegate?.didSelectNextAction(currentQuestion: currentQuestion, selectedAnswer: .noneOfTheAbove(ChildSymptom(id: selected)))
				}
			default:
				break
		}
	}
}

