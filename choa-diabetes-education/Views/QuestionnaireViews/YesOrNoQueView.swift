//
//  YesOrNoQueView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol YesOrNoQueViewProtocol: AnyObject {
    func didSelectNextAction(currentQuestion: Questionnaire, userSelectedType: YesOrNo)
}

class YesOrNoQueView: UIView {
    static let nibName = "YesOrNoQueView"
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionLabelAtBottom: UILabel!
    @IBOutlet weak var yesButton: RoundedButton!
    @IBOutlet weak var noButton: RoundedButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextButton: PrimaryButton!
    
    @IBOutlet weak var descriptionLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTopConstraint: NSLayoutConstraint!
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
        
        questionLabel.font = .gothamRoundedBold16
        questionLabel.numberOfLines = 2
        questionLabel.textColor = .headingGreenColor
        questionLabel.text = currentQuestion.question
        questionLabel.textAlignment = .left
        
        if let answerOptions = currentQuestion.answerOptions {
            yesButton.setTitle(answerOptions[0].localized(), for: .normal)
            noButton.setTitle(answerOptions[1].localized(), for: .normal)
        }
        
        if let currDesctiption = currentQuestion.description, currDesctiption != "" {
            if currentQuestion.showDescriptionAtBottom {
                
                descriptionLabelTopConstraint.constant = 0
                descriptionLabel.isHidden = true
                buttonTopConstraint.constant = 0
                
                descriptionLabelAtBottom.isHidden = false
                descriptionLabelAtBottom.font = .avenirLight14
                descriptionLabelAtBottom.numberOfLines = 0
                descriptionLabelAtBottom.textColor = .headingGreenColor
                descriptionLabelAtBottom.text = currDesctiption
                descriptionLabelAtBottom.textAlignment = .left
            } else {
                descriptionLabelAtBottom.isHidden = true
                descriptionLabelTopConstraint.constant = 10
                buttonTopConstraint.constant = 30
                descriptionLabel.isHidden = false
                descriptionLabel.font = .avenirLight14
                descriptionLabel.numberOfLines = 0
                descriptionLabel.textColor = .headingGreenColor
                descriptionLabel.text = currDesctiption
                descriptionLabel.textAlignment = .left
            }
        } else {
            descriptionLabelTopConstraint.constant = 0
            descriptionLabel.isHidden = true
            descriptionLabelAtBottom.isHidden = true
            buttonTopConstraint.constant = 0
        }
    }
    
    @IBAction func didYesButtonTap(_ sender: UIButton) {
        noButton.updateButtonForDeselection()
        yesButton.updateButtonForSelection()
    }
    
    @IBAction func didNoButtonTap(_ sender: UIButton) {
        noButton.updateButtonForSelection()
        yesButton.updateButtonForDeselection()
    }
    
    @IBAction func didNextButtonTap(_ sender: UIButton) {
        if yesButton.isSelected {
            delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedType: .yes)
        } else if noButton.isSelected {
            delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedType: .no)
        }
    }
}
