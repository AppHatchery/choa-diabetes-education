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
	}

	func followUpView(_ view: TwoOptionsFollowUpQuestionView, didSelect answer: Int) {
		self.followUpAnswer = answer
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
        
        questionLabel.font = .gothamRoundedMedium
        questionLabel.numberOfLines = 5
        questionLabel.textColor = .headingGreenColor
        questionLabel.text = currentQuestion.question
        questionLabel.textAlignment = .left
        
        if let answerOptions = currentQuestion.answerOptions {
            yesButton.setTitle(answerOptions[0].localized(), for: .normal)
            noButton.setTitle(answerOptions[1].localized(), for: .normal)
        }

		nextButton.alpha = 0.3
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

		default:
			break
		}

		nextButton.alpha = 1
    }
    
    @IBAction func didNoButtonTap(_ sender: UIButton) {
        noButton.updateButtonForSelection()
        yesButton.updateButtonForDeselection()

		followUpQuestionStackView.subviews.forEach { $0.removeFromSuperview() }

		nextButton.alpha = 1
    }
    
    @IBAction func didNextButtonTap(_ sender: UIButton) {
        if yesButton.isSelected {
			guard followUpAnswer != 0 else { return }
            delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedType: .yes)
        } else if noButton.isSelected {
            delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedType: .no)
        }
    }


	@IBAction func didTapExitButton(_ sender: UIButton) {
		delegate?.didSelectExitAction()
	}
}
