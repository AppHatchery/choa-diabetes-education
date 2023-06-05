//
//  MultipleOptionsView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol MultipleOptionsViewProtocol: AnyObject {
    func didSelectNextAction(currentQuestion: Questionnaire, userSelectedType: KetonesType)
}

class MultipleOptionsView: UIView {
    static let nibName = "MultipleOptionsView"
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var firstButton: RoundedButton!
    @IBOutlet weak var secondButton: RoundedButton!
    @IBOutlet weak var thirdButton: RoundedButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextButton: PrimaryButton!
    
    private var currentQuestion: Questionnaire!
    weak var delegate: MultipleOptionsViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        Bundle.main.loadNibNamed(MultipleOptionsView.nibName, owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func setupView(currentQuestion: Questionnaire) {
        self.currentQuestion = currentQuestion
        questionLabel.font = .gothamRoundedBold16
        questionLabel.numberOfLines = 0
        questionLabel.textColor = .headingGreenColor
        questionLabel.text = currentQuestion.question
        questionLabel.textAlignment = .left
        
        if let answerOptions = currentQuestion.answerOptions {
            firstButton.setTitle(answerOptions[0].localized(), for: .normal)
            secondButton.setTitle(answerOptions[1].localized(), for: .normal)
            thirdButton.setTitle(answerOptions[2].localized(), for: .normal)
        }
        
        descriptionLabel.font = .avenirLight14
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .headingGreenColor
        descriptionLabel.text = currentQuestion.description
        descriptionLabel.textAlignment = .left
    }
    
    @IBAction func didFirstButtonTap(_ sender: UIButton) {
        firstButton.updateButtonForSelection()
        secondButton.updateButtonForDeselection()
        thirdButton.updateButtonForDeselection()
    }
    
    @IBAction func didSecondButtonTap(_ sender: UIButton) {
        secondButton.updateButtonForSelection()
        firstButton.updateButtonForDeselection()
        thirdButton.updateButtonForDeselection()
    }
    
    @IBAction func didThirdButtonTap(_ sender: UIButton) {
        thirdButton.updateButtonForSelection()
        secondButton.updateButtonForDeselection()
        firstButton.updateButtonForDeselection()
    }
    
    @IBAction func didNextButtonTap(_ sender: UIButton) {
        if firstButton.isSelected {
            delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedType: .urineKetones)
        } else if secondButton.isSelected {
            delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedType: .bloodKetones)
        } else {
            delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedType: .none)
        }
    }
}