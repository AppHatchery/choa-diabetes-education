//
//  YesOrNoQueView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol YesOrNoQueViewProtocol: AnyObject {
    func didSelectNextAction(currentQuestion: Questionnaire, userSelectedType: YesOrNo)

	func didSelectExitAction()
}

class YesOrNoQueView: UIView {
    static let nibName = "YesOrNoQueView"
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var yesButton: RoundedButton!
    @IBOutlet weak var noButton: RoundedButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextButton: PrimaryButton!

    private var currentQuestion: Questionnaire!
    weak var delegate: YesOrNoQueViewProtocol?
    
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
        
        if let currDesctiption = currentQuestion.description, currDesctiption != "" {
            if currentQuestion.showDescriptionAtBottom {
                
                print("Description At Bottom: \(currDesctiption)")
            } else {
				print("Description At Top: \(currDesctiption)")
            }
        } else {
			print("No Description")
        }

		nextButton.alpha = 0.3
    }
    
    @IBAction func didYesButtonTap(_ sender: UIButton) {
        noButton.updateButtonForDeselection()
        yesButton.updateButtonForSelection()

		nextButton.alpha = 1
    }
    
    @IBAction func didNoButtonTap(_ sender: UIButton) {
        noButton.updateButtonForSelection()
        yesButton.updateButtonForDeselection()

		nextButton.alpha = 1
    }
    
    @IBAction func didNextButtonTap(_ sender: UIButton) {
        if yesButton.isSelected {
            delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedType: .yes)
        } else if noButton.isSelected {
            delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedType: .no)
        }
    }


	@IBAction func didTapExitButton(_ sender: UIButton) {
		delegate?.didSelectExitAction()
	}
}
