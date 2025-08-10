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
    @IBOutlet weak var firstButton: RoundedButton!
    @IBOutlet weak var secondButton: RoundedButton!
    @IBOutlet weak var thirdButton: RoundedButton!
    @IBOutlet weak var fourthButton: RoundedButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextButton: PrimaryButton!
	@IBOutlet var exitButton: UIButton!

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
        
        if let answerOptions = currentQuestion.answerOptions {
            firstButton.setTitle(answerOptions[0].localized(), for: .normal)
            secondButton.setTitle(answerOptions[1].localized(), for: .normal)
            thirdButton.setTitle(answerOptions[2].localized(), for: .normal)
            fourthButton.setTitle(answerOptions[3].localized(), for: .normal)
        }
    }
    
    @IBAction func didFirstButtonTap(_ sender: UIButton) {
        selected = 1
        firstButton.updateButtonForSelection()
        secondButton.updateButtonForDeselection()
        thirdButton.updateButtonForDeselection()
        fourthButton.updateButtonForDeselection()
    }
    
    @IBAction func didSecondButtonTap(_ sender: UIButton) {
        selected = 2
        secondButton.updateButtonForSelection()
        firstButton.updateButtonForDeselection()
        thirdButton.updateButtonForDeselection()
        fourthButton.updateButtonForDeselection()
    }
    
    @IBAction func didThirdButtonTap(_ sender: UIButton) {
        selected = 3
        thirdButton.updateButtonForSelection()
        secondButton.updateButtonForDeselection()
        firstButton.updateButtonForDeselection()
        fourthButton.updateButtonForDeselection()
    }
    
    @IBAction func didFourthButtonTap(_ sender: UIButton) {
        selected = 4
        fourthButton.updateButtonForSelection()
        firstButton.updateButtonForDeselection()
        thirdButton.updateButtonForDeselection()
        secondButton.updateButtonForDeselection()
        
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
			} else {
				delegate?.didSelectNextAction(currentQuestion: currentQuestion, selectedAnswer: .LowBloodSugar(ChildIssue(id: selected))
				)
			}
		default:
			break
		}
    }


	@IBAction func didTapExitButton(_ sender: UIButton) {
		delegate?.didSelectExitAction()
	}
}
