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

	private var questionLabel: UILabel!
		// Please note that this will also be for TwoOption type questions so the yes/no buttons shouldn't restrict the question type
	private var option1Button: RoundedButton!
	private var option2Button: RoundedButton!

	private var currentQuestion: Questionnaire!
	weak var delegate: TwoOptionsFollowUpDelegate?
	weak var yesOrNoDelegate: YesOrNoFollowUpDelegate?

	private var selected = 0

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}

	private func setupUI() {
		questionLabel = UILabel()
		questionLabel.translatesAutoresizingMaskIntoConstraints = false
		questionLabel.numberOfLines = 0
		questionLabel.textAlignment = .left
		addSubview(questionLabel)

		option1Button = RoundedButton()
		option1Button.translatesAutoresizingMaskIntoConstraints = false
		option1Button.addTarget(self, action: #selector(option1Tapped), for: .touchUpInside)
		addSubview(option1Button)

		option2Button = RoundedButton()
		option2Button.translatesAutoresizingMaskIntoConstraints = false
		option2Button.addTarget(self, action: #selector(option2Tapped), for: .touchUpInside)
		addSubview(option2Button)

		setupConstraints()
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			questionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
			questionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			questionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

			option1Button.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 0),
			option1Button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			option1Button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
			option1Button.heightAnchor.constraint(equalToConstant: 44),

			option2Button.topAnchor.constraint(equalTo: option1Button.bottomAnchor, constant: 8),
			option2Button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			option2Button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			option2Button.heightAnchor.constraint(equalToConstant: 44),

			bottomAnchor.constraint(equalTo: option2Button.bottomAnchor, constant: 8)
		])
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
