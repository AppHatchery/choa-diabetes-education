//
//  TwoOptionsFollowUpQuestionView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 16/07/2025.
//

import Foundation
import UIKit

class TwoOptionsFollowUpQuestionView: UIView {
    protocol TwoOptionsFollowUpDelegate: AnyObject {
        func followUpView(_ view: TwoOptionsFollowUpQuestionView, didSelect answer: Int)
    }

	protocol YesOrNoFollowUpDelegate: AnyObject {
		func followUpView(_ view: YesOrNoFollowUpView, didSelect answer: Int)
	}


	@IBOutlet var questionLabel: UILabel!
		// Please note that this will also be for TwoOption type questions so the yes/no buttons shouldn't restrict the question type
	@IBOutlet var option1Button: RoundedButton!
	@IBOutlet var option2Button: RoundedButton!


	private var currentQuestion: Questionnaire!
	weak var delegate: TwoOptionsFollowUpDelegate?
	weak var yesOrNoDelegate: YesOrNoFollowUpDelegate?

	private var selected = 0

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

	@objc private func option1Tapped() {
		selected = 1
		option1Button.updateButtonForSelection()
		option2Button.updateButtonForDeselection()
        delegate?.followUpView(self, didSelect:selected)

		switch currentQuestion.questionId {

		case TwoOptionsQuestionId.testType.id:
			self.delegate?.followUpView(self, didSelect: selected)
			print("Follow up answer FROM YES OR NO FOLLOW UP VIEW: \(selected)")
		default:
			break
		}
	}

	@objc private func option2Tapped() {
		selected = 2
		option1Button.updateButtonForDeselection()
		option2Button.updateButtonForSelection()
        delegate?.followUpView(self, didSelect: selected)

		switch currentQuestion.questionId {

		case TwoOptionsQuestionId.testType.id:
			self.delegate?.followUpView(self, didSelect: selected)
			
			print("Follow up answer FROM YES OR NO FOLLOW UP VIEW: \(selected)")
		default:
			break
		}
	}

	func setupView(currentQuestion: Questionnaire) {
		self.currentQuestion = currentQuestion

		questionLabel.font = .gothamRoundedBold16
		questionLabel.numberOfLines = 0
		questionLabel.textColor = .headingGreenColor

		questionLabel.textAlignment = .left

		switch currentQuestion.questionId {

		case TwoOptionsQuestionId.testType.id:
			questionLabel.text = "Calculator.Que.Method.title".localized()

			option1Button.setTitle("Calculator.Que.Method.option1".localized(), for: .normal)
			option2Button.setTitle("Calculator.Que.Method.option2".localized(), for: .normal)
		default:
			break
		}

	}
}
