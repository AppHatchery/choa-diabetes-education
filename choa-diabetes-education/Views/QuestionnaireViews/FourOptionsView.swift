//
//  FourOptionsView.swift
//  choa-diabetes-education
//

import Foundation
import UIKit

protocol FourOptionsViewProtocol: AnyObject {
    func didSelectNextAction(currentQuestion: Questionnaire, selectedAnswer: FourOptionsAnswer)
}

class FourOptionsView: UIView {
    static let nibName = "FourOptionsView"
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var firstButton: RoundedButton!
    @IBOutlet weak var secondButton: RoundedButton!
    @IBOutlet weak var thirdButton: RoundedButton!
    @IBOutlet weak var fourthButton: RoundedButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextButton: PrimaryButton!
    
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
        questionLabel.font = .gothamRoundedBold16
        questionLabel.numberOfLines = 0
        questionLabel.textColor = .headingGreenColor
        questionLabel.text = currentQuestion.question
        questionLabel.textAlignment = .left
        
        if let answerOptions = currentQuestion.answerOptions {
            firstButton.setTitle(answerOptions[0].localized(), for: .normal)
            secondButton.setTitle(answerOptions[1].localized(), for: .normal)
            thirdButton.setTitle(answerOptions[2].localized(), for: .normal)
            fourthButton.setTitle(answerOptions[3].localized(), for: .normal)
            
        }
        
        descriptionLabel.font = .avenirLight14
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .headingGreenColor
        descriptionLabel.text = currentQuestion.description
        descriptionLabel.textAlignment = .left
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
        case FourOptionsQueID.lastBasalInjection.id:
            delegate?.didSelectNextAction(currentQuestion: currentQuestion, selectedAnswer: FourOptionsAnswer.ScheduledTime(ScheduledTime(id: selected)))
            
            default:
                break
            
        }
    }
}
