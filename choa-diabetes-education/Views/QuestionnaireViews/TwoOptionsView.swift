//
//  TwoOptionsView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol TwoOptionsViewProtocol: AnyObject {
    func didSelectNextAction(currentQuestion: Questionnaire, userSelectedType: TestType)
}

class TwoOptionsView: UIView {
    static let nibName = "TwoOptionsView"
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var firstButton: RoundedButton!
    @IBOutlet weak var secondButton: RoundedButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextButton: PrimaryButton!
    
    @IBOutlet weak var descriptionLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTopConstraint: NSLayoutConstraint!
    private var currentQuestion: Questionnaire!
    weak var delegate: TwoOptionsViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        Bundle.main.loadNibNamed(TwoOptionsView.nibName, owner: self)
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
        }
        
        guard let description = currentQuestion.description, description != "" else {
            descriptionLabelTopConstraint.constant = 0
            descriptionLabel.isHidden = true
            buttonTopConstraint.constant = 0
            return
        }
        descriptionLabelTopConstraint.constant = 10
        buttonTopConstraint.constant = 30
        descriptionLabel.isHidden = false
        descriptionLabel.font = .avenirLight14
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .headingGreenColor
        descriptionLabel.text = description
        descriptionLabel.textAlignment = .left
    }
    
    @IBAction func didFirstButtonTap(_ sender: UIButton) {
        secondButton.updateButtonForDeselection()
        firstButton.updateButtonForSelection()
    }
    
    @IBAction func didSecondButtonTap(_ sender: UIButton) {
        secondButton.updateButtonForSelection()
        firstButton.updateButtonForDeselection()
    }
    
    @IBAction func didNextButtonTap(_ sender: UIButton) {
        if firstButton.isSelected {
            delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedType: .pump)
        } else {
            delegate?.didSelectNextAction(currentQuestion: currentQuestion, userSelectedType: .insulinShots)
        }
    }
}
