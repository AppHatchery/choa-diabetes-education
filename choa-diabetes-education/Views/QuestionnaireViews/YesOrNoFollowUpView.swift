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
		func followUpView(_ view: YesOrNoFollowUpView, didSelect answer: Int)
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
	}

		// MARK: - Actions
	@IBAction private func yesButtonTapped(_ sender: RoundedButton) {
			// Handle yes button tap
		delegate?.followUpView(self, didSelect: selected)
	}

	@IBAction private func noButtonTapped(_ sender: RoundedButton) {
		delegate?.followUpView(self, didSelect: selected)

	}

	func setupView(currentQuestion: Questionnaire) {
		self.currentQuestion = currentQuestion

		questionLabel.font = .gothamRoundedBold16
		questionLabel.numberOfLines = 0
		questionLabel.textColor = .headingGreenColor

		questionLabel.textAlignment = .left

		switch currentQuestion.questionId {

		case TwoOptionsQuestionId.testType.id:
			questionLabel.text = "Calculator.Que.IletPump.title".localized()

			yesButton.setTitle("Yes".localized(), for: .normal)
			noButton.setTitle("No".localized(), for: .normal)
		default:
			break
		}

	}
}
