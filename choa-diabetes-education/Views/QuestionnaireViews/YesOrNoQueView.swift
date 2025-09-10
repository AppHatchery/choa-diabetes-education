//
//  YesOrNoQueView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol YesOrNoQueViewProtocol: AnyObject {
    func didSelectNextAction(currentQuestion: Questionnaire, userSelectedType: YesOrNo)

	func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: YesOrNo, followUpAnswer: YesOrNo?)

	func didSelectExitAction()
}

class YesOrNoQueView: UIView, YesOrNoFollowUpView.YesOrNoFollowUpViewDelegate {
	func yesOrNoFollowUpView(_ view: YesOrNoFollowUpView, didSelect answer: Int) {
		self.followUpAnswer = answer

		nextButton.alpha = 1
	}

	func followUpView(_ view: TwoOptionsFollowUpQuestionView, didSelect answer: Int) {
		self.followUpAnswer = answer

		nextButton.alpha = 1
	}

    static let nibName = "YesOrNoQueView"
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var yesButton: RoundedButton!
    @IBOutlet weak var noButton: RoundedButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextButton: PrimaryButton!
	@IBOutlet var followUpQuestionStackView: UIStackView!

    private var currentQuestion: Questionnaire!
    weak var delegate: YesOrNoQueViewProtocol?

	private var followUpAnswer = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        Bundle.main.loadNibNamed(YesOrNoQueView.nibName, owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func setupView(currentQuestion: Questionnaire) {
        self.currentQuestion = currentQuestion

		followUpAnswer = 0

        questionLabel.font = .gothamRoundedMedium
        questionLabel.numberOfLines = 5
        questionLabel.textColor = .headingGreenColor
        questionLabel.text = currentQuestion.question
        questionLabel.textAlignment = .left
        
        if let answerOptions = currentQuestion.answerOptions {
			yesButton.titleLabel?.text = answerOptions[0].localized()
			noButton.titleLabel?.text = answerOptions[1].localized()
        }

		if followUpAnswer == 0 {
			nextButton.alpha = 0.3
		}

		nextButton.titleLabel?.font = .gothamRoundedMedium20
    }
    
    @IBAction func didYesButtonTap(_ sender: UIButton) {
        noButton.updateButtonForDeselection()
        yesButton.updateButtonForSelection()

		switch currentQuestion.questionId {
		case YesOrNoQuestionId.bloodSugarCheck.id:
				// Guard against adding duplicate YesOrNoFollowUpView
			if followUpQuestionStackView.subviews.contains(where: { $0 is YesOrNoFollowUpView }) {
				return
			}

			QuestionnaireManager.instance.saveBloodSugarOver300(true)

				// Clear any existing subviews first
			followUpQuestionStackView.subviews.forEach { $0.removeFromSuperview() }

			let followUpSubview = YesOrNoFollowUpView()

			followUpSubview.translatesAutoresizingMaskIntoConstraints = false
			followUpQuestionStackView.addArrangedSubview(followUpSubview)

			NSLayoutConstraint.activate([
				followUpSubview.leadingAnchor.constraint(equalTo: followUpQuestionStackView.leadingAnchor),
				followUpSubview.trailingAnchor.constraint(equalTo: followUpQuestionStackView.trailingAnchor)
			])

			followUpSubview.delegate = self
			
			followUpSubview.setupView(currentQuestion: currentQuestion)

			nextButton.alpha = 0.3
		case YesOrNoQuestionId.bloodSugarRecheck.id:
			nextButton.alpha = 1
		default:
			break
		}
    }
    
    @IBAction func didNoButtonTap(_ sender: UIButton) {
        noButton.updateButtonForSelection()
        yesButton.updateButtonForDeselection()

		followUpQuestionStackView.subviews.forEach { $0.removeFromSuperview() }

		if currentQuestion.questionId == YesOrNoQuestionId.bloodSugarCheck.id {
			QuestionnaireManager.instance.saveBloodSugarOver300(false)

			nextButton.alpha = 1
		} else if currentQuestion.questionId == YesOrNoQuestionId.bloodSugarRecheck.id {
			nextButton.alpha = 1
		}
    }
    
    @IBAction func didNextButtonTap(_ sender: UIButton) {
        if yesButton.isSelected {
			if currentQuestion.questionId == YesOrNoQuestionId.bloodSugarCheck.id {
				
				guard followUpAnswer != 0 else { return }
			}
            delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedType: .yes)
        } else if noButton.isSelected {
            delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedType: .no)
        }
    }


	@IBAction func didTapExitButton(_ sender: UIButton) {
		delegate?.didSelectExitAction()
	}
}
