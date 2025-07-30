//
//  TwoOptionsFollowUpQuestionView.swift
//  choa-diabetes-education
//
//  Created by Maxwell Kapezi Jr on 16/07/2025.
//

import Foundation
import UIKit

class TwoOptionsFollowUpQuestionView: UIView {
    protocol YesOrNoFollowUpDelegate: AnyObject {
        func followUpView(_ view: TwoOptionsFollowUpQuestionView, didSelect answer: Int)
    }

	private var questionLabel: UILabel!
		// Please note that this will also be for TwoOption type questions so the yes/no buttons shouldn't restrict the question type
	private var yesButton: RoundedButton!
	private var noButton: RoundedButton!

	private var currentQuestion: Questionnaire!
	weak var delegate: YesOrNoFollowUpDelegate?

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

		yesButton = RoundedButton()
		yesButton.translatesAutoresizingMaskIntoConstraints = false
		yesButton.addTarget(self, action: #selector(yesButtonTapped), for: .touchUpInside)
		addSubview(yesButton)

		noButton = RoundedButton()
		noButton.translatesAutoresizingMaskIntoConstraints = false
		noButton.addTarget(self, action: #selector(noButtonTapped), for: .touchUpInside)
		addSubview(noButton)

		setupConstraints()
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			questionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
			questionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			questionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

			yesButton.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 0),
			yesButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			yesButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
			yesButton.heightAnchor.constraint(equalToConstant: 44),

			noButton.topAnchor.constraint(equalTo: yesButton.bottomAnchor, constant: 8),
			noButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			noButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			noButton.heightAnchor.constraint(equalToConstant: 44),

			bottomAnchor.constraint(equalTo: noButton.bottomAnchor, constant: 8)
		])
	}

	@objc private func yesButtonTapped() {
		selected = 1
		yesButton.updateButtonForSelection()
		noButton.updateButtonForDeselection()
        delegate?.followUpView(self, didSelect:selected)

		switch currentQuestion.questionId {

		case TwoOptionsQuestionId.testType.id:
			self.delegate?.followUpView(self, didSelect: selected)
			print("Follow up answer FROM YES OR NO FOLLOW UP VIEW: \(selected)")
		default:
			break
		}
	}

	@objc private func noButtonTapped() {
		selected = 2
		yesButton.updateButtonForDeselection()
		noButton.updateButtonForSelection()
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

			yesButton.setTitle("Calculator.Que.Method.option1".localized(), for: .normal)
			noButton.setTitle("Calculator.Que.Method.option2".localized(), for: .normal)
		default:
			break
		}

	}
}
