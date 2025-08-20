//
//  FourOptionsView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol FourOptionsViewProtocol: AnyObject {
    func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: FourOptionsAnswer)

	func didSelectExitAction()
}

class FourOptionsView: UIView {
    static let nibName = "FourOptionsView"
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextButton: PrimaryButton!
	@IBOutlet var exitButton: UIButton!

	@IBOutlet var optionButtons: [UIView]!
	@IBOutlet var optionButtonLabels: [UILabel]!

	@IBOutlet var firstButtonLabel: UILabel!
	@IBOutlet var secondButtonLabel: UILabel!
	@IBOutlet var thirdButtonLabel: UILabel!
	@IBOutlet var fourthButtonLabel: UILabel!

	private var currentQuestion: Questionnaire!
    weak var delegate: FourOptionsViewProtocol?
    
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
        Bundle.main.loadNibNamed(FourOptionsView.nibName, owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func setupView(currentQuestion: Questionnaire) {
        self.currentQuestion = currentQuestion
		questionLabel.font = .gothamRoundedMedium
        questionLabel.numberOfLines = 0
		questionLabel.textColor = .primaryBlue
        questionLabel.text = currentQuestion.question
        questionLabel.textAlignment = .left

		optionButtons.forEach {
			$0.layer.cornerRadius = 8
		}

		for (index, view) in optionButtons.enumerated() {
			view.isUserInteractionEnabled = true
			let tap = UITapGestureRecognizer(target: self, action: #selector(optionButtonViewTapped(_:)))
			view.addGestureRecognizer(tap)
			view.tag = index
		}

        if let answerOptions = currentQuestion.answerOptions {
			firstButtonLabel.text = answerOptions[0].localized()
			secondButtonLabel.text = answerOptions[1].localized()
			thirdButtonLabel.text = answerOptions[2].localized()
			fourthButtonLabel.text = answerOptions[3].localized()
        }
    }

	@objc private func optionButtonViewTapped(_ sender: UITapGestureRecognizer) {
		guard let tappedView = sender.view else { return }

			// Loop through all views & labels
		for (index, view) in optionButtons.enumerated() {
			let label = optionButtonLabels[index]
			if index == tappedView.tag {
				selected = index + 1
				view.updateViewForSelection()
				label.updateLabelForSelection()
				print("Selected FOUR OPTIONS Answer: \(selected)")
			} else {
				view.updateViewForDeselection()
				label.updateLabelForDeselection()
			}
		}
	}
    
    @IBAction func didNextButtonTap(_ sender: UIButton) {
        if selected == 0 { return }

		switch currentQuestion.questionId {
		case FourOptionsQuestionId.childIssue.id:
			if selected == 1 {
				delegate?
					.didSelectNextAction(
						currentQuestion: currentQuestion,
						selectedAnswer: .DKAIssue(ChildIssue(id: selected))
					)
			} else if selected == 2 {
				delegate?.didSelectNextAction(
					currentQuestion: currentQuestion,
					selectedAnswer: .HighBloodSugar(ChildIssue(id: selected))
				)
			} else if selected == 3 {
				delegate?.didSelectNextAction(
					currentQuestion: currentQuestion,
					selectedAnswer: .LowBloodSugar(ChildIssue(id: selected))
				)
			}

//			else {
//				delegate?
//					.didSelectNextAction(
//						currentQuestion: currentQuestion,
//						selectedAnswer: .NotSure(
//							ChildIssue(id: selected)
//						)
//				)
//			}
		default:
			break
		}
    }


	@IBAction func didTapExitButton(_ sender: UIButton) {
		delegate?.didSelectExitAction()
	}
}
