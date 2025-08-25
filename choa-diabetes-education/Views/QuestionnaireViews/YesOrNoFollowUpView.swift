//
//  YesOrNoFollowUpView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 30/07/2025.
//

import Foundation
import UIKit

class YesOrNoFollowUpView: UIView {
	protocol YesOrNoFollowUpViewDelegate: AnyObject {
		func yesOrNoFollowUpView(_ view: YesOrNoFollowUpView, didSelect answer: Int)
	}

	@IBOutlet var questionLabel: UILabel!
	@IBOutlet var yesButton: RoundedButton!
	@IBOutlet var noButton: RoundedButton!
	@IBOutlet var contentView: UIView!
	
	weak var delegate: YesOrNoFollowUpViewDelegate?

	private var selected = 0

	private var currentQuestion: Questionnaire!

		// MARK: - XIB Loading
	override init(frame: CGRect) {
		super.init(frame: frame)
		loadFromNib()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		loadFromNib()
	}

	private func loadFromNib() {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
		
		guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
			return
		}

		addSubview(view)
		view.frame = self.bounds
		view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}

		// MARK: - Actions
	@IBAction private func yesButtonTapped(_ sender: RoundedButton) {
		selected = 1
		delegate?.yesOrNoFollowUpView(self, didSelect: selected)

		yesButton.updateButtonForSelection()
		noButton.updateButtonForDeselection()
	}

	@IBAction private func noButtonTapped(_ sender: RoundedButton) {
		selected = 2
		delegate?.yesOrNoFollowUpView(self, didSelect: selected)

		noButton.updateButtonForSelection()
		yesButton.updateButtonForDeselection()
	}

	func setupView(currentQuestion: Questionnaire) {
		self.currentQuestion = currentQuestion

		questionLabel.font = .gothamRoundedMedium
		questionLabel.numberOfLines = 0
		questionLabel.textColor = .headingGreenColor

		questionLabel.textAlignment = .left

		selected = 0

		switch currentQuestion.questionId {

		case TwoOptionsQuestionId.testType.id:
			questionLabel.text = "Calculator.Que.IletPump.title".localized()

			yesButton.titleLabel?.text = "Yes".localized()
			noButton.titleLabel?.text = "No".localized()

		case YesOrNoQuestionId.bloodSugarCheck.id:
			questionLabel.text = QuestionnaireManager.instance.iLetPump ? "Calculator.Que.ILetPumpBloodSugarTimeCheck.title".localized() : "Calculator.Que.BloodSugarTimeCheck.title".localized()

			yesButton.titleLabel?.text = "Yes".localized()
			noButton.titleLabel?.text = "No".localized()
		default:
			break
		}
	}
}
